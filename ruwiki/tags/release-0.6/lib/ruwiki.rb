#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
require 'cgi'
require 'ruwiki/handler'
require 'ruwiki/template'
require 'ruwiki/config'
require 'ruwiki/backend'
require 'ruwiki/wiki'
require 'ruwiki/page'
require 'ruwiki/abbreviations'

  # = Ruwiki
  # Ruwiki is a simple, extensible Wiki written in Ruby. It supports both CGI
  # and WEBrick interfaces, templates, and CSS formatting. Additionally, it
  # supports project namespaces, so that two pages can be named the same for
  # differing projects without colliding or having to resort to odd naming
  # conventions. Please see ::Ruwiki in the running Wiki for more information.
  #
  # == Quick Install (CGI)
  # 1. Place the Ruwiki directory in a place that your webserver can execute
  #    CGI programs. Ensure that ruwiki.cgi is executable on your webserver.
  #    You may wish to protect templates/, data/, and lib/ from casual access.
  # 2. Modify the following lines in ruwiki.cgi:
  #     wiki.config.webmaster  = ...
  #     wiki.config.title      = ...
  # 3. Point your web browser to the appropriate URL.
  #
  # == Quick Install (WEBrick)
  # 1. Modify the following lines in ruwiki_servlet.rb:
  #     $config.webmaster  = ...
  #     $config.title      = ...
  # 2. Run ruwiki_servlet.rb to start a WEBrick instance on localhost:8808 with
  #   ruwiki bound to the root path (e.g., http://localhost:8808/).
  # 3. Point your web browser to the appropriate URL.
  #
  # == Use
  # Ruwiki is able to be called with one of several URI forms:
  #
  #   http://domain.com/ruwiki.cgi?PageName
  #   http://domain.com/ruwiki.cgi?PageName&project=Project
  #   http://domain.com/ruwiki.cgi/PageName
  #   http://domain.com/ruwiki.cgi/Project/
  #   http://domain.com/ruwiki.cgi/Project/PageName
  #
  # Copyright:: Copyright © 2003 - 2003, Digikata and HaloStatue, Ltd.
  # Authors::   Alan Chen (alan@digikata.com)
  #             Austin Ziegler (ruwiki@halostatue.ca)
  # Licence::   Ruby's
class Ruwiki
  VERSION         = '0.6.0.0'

  ALLOWED_ACTIONS = ['edit', 'save', 'cancel']
  POST_VARS       = ['newpage', 'pagename', 'project']
  RESERVED        = ['action', ALLOWED_ACTIONS, POST_VARS].flatten

    # Returns the known abbreviations.
  attr_accessor :abbr
    # Returns the current configuration object.
  attr_reader :config
    # Returns the current Response object.
  attr_reader :response
    # Returns the current Request object.
  attr_reader :request
    # Returns the current Markup object.
  attr_reader :markup
    # Returns the current Backend object.
  attr_reader :backend

    # Sets the configuration object to a new configuration object.
  def config=(c)
    raise "Configuration must be of class Ruwiki::Config." unless c.kind_of?(Ruwiki::Config)
    @config = c
  end

    # Initializes Ruwiki. 
  def initialize(handler)
    @request    = handler.request
    @response   = handler.response

    @config     = Ruwiki::Config.new
    @abbr       = Ruwiki::ABBREVIATIONS
    @request    = request
    @response   = response
    @path_info  = @request.determine_request_path

    @type       = nil
    @error      = {}

    @markup     = Ruwiki::Wiki.new(self)
  end

    # Initializes the backend for Ruwiki.
  def set_backend
    @backend = Backend[@config.storage_type, self]
  end

    # Runs the steps to process the wiki.
  def run
    @config.verify
    set_backend
    set_page
    process_page
    render
  rescue Exception => e
    render(:error, e)
  ensure
    output
  end

    # Initializes current page for Ruwiki.
  def set_page
    if @path_info.nil? or @path_info.empty? or @path_info == "/"
      @request.each_parameter do |key, val|
        next if RESERVED.include?(key)
        @page_name = key
      end
      @project_name = @request.parameters['project']
      @project_name ||= @config.default_project
      @page_name    ||= @config.default_page
    else
      pi = @path_info.split("/", -1)
      case pi.size
      when 1
        @page_name    = @config.default_page
        @project_name = @config.default_project
      when 2
        if pi[1].nil? or pi[1].empty?
          @page_name  = @config.default_page
        else
          @page_name    = pi[1]
        end
        @project_name = @config.default_project
      else
        if pi[2].nil? or pi[2].empty?
          @page_name    = @config.default_page
          @project_name = pi[1]
        else
          @page_name    = pi[2]
          @project_name = pi[1]
        end
      end
    end
  end

    # Processes the page through the necessary steps. This is where the edit,
    # save, cancel, and display actions are present.
  def process_page
    content   = nil
    @page     = @backend.retrieve(@page_name, @project_name)
    @type     = :content

    if @request.parameters['action']
      case @request.parameters['action'].downcase.intern
      when :edit
        @backend.obtain_lock(@page)
        content = nil
        @type = :edit
      when :save
        @page.topic       = @request.parameters['topic']
        @page.project     = @request.parameters['project']
        @page.content     = @request.parameters['newpage']
        @page.old_version = @request.parameters['old_version'].to_i + 1
        @page.version     = @request.parameters['version'].to_i + 1

        content = @page.to_html
        @backend.store(@page)
        @backend.release_lock(@page)
        @type = :save
      when :cancel
        @page.topic       = @request.parameters['topic']
        @page.project     = @request.parameters['project']
        @page.content     = @request.parameters['origpage'].unpack("m*")[0]
        @page.old_version = @request.parameters['old_version'].to_i
        @page.version     = @request.parameters['version'].to_i
        content           = @page.to_html
        @backend.release_lock(@page)
      end
    else
      content = @page.to_html
    end
  rescue Exception => e
    @type = :error
    if e.kind_of?(Ruwiki::Backend::BackendError)
      @error[:name] = "Error: #{e.to_s}"
    else
      @error[:name] = "Complete and Utter Failure: #{e.to_s}"
    end
    @error[:backtrace] = e.backtrace.join
    content = nil
  ensure
    @content = content
  end

    # Renders the page.
  def render(*args)
    if args.empty?
      type  = @type
      error = @error
    else
      raise ArgumentError, "#render must be called with zero or two arguments." unless args.size == 2
      type  = args[0]
      error = {}
      error[:name] = args[1].inspect.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')
      error[:backtrace] = args[1].backtrace.join("<br />\n")
    end

    @rendered_page = ""
    values = { "css_link" => @config.css_link,
               "home_link" => %Q(<a href="#{@request.script_url}">#{@config.title}</a>) }

    case type
    when :content, :save
      values["wiki_title"]    = "Error - #{@config.title}" if @page.nil?
      values["wiki_title"]  ||= "#{@page.project}::#{@page.topic} - #{@config.title}"
      values["page_tolink"]   = @page.to_link
      values["page_topic"]    = @page.topic
      values["page_project"]  = @page.project
      values["cgi_url"]       = @request.script_url
      values["content"]       = @content
      if type == :content
        template = TemplatePage.new(@config.template(:body), @config.template(:content), @config.template(:controls))
      else
        template = TemplatePage.new(@config.template(:body), @config.template(:save), @config.template(:controls))
      end
    when :edit
      template = TemplatePage.new(@config.template(:body), @config.template(:edit))
      values["wiki_title"] = "Editing: #{@page.project}::#{@page.topic} - #{@config.title}"
      values["page_topic"] = @page.topic
      values["page_project"] = @page.project
      values["cgi_url"] = @request.script_url
      values["page_content"] = @page.content
      values["orig_page"] = [@page.content].pack("m*")
      values["page_old_version"] = @page.old_version.to_s
      values["page_version"] = @page.version.to_s
      values["unedited_page_content"] = @page.to_html
      values["pre_page_content"] = CGI.escapeHTML(@page.content)
    when :error
      template = TemplatePage.new(@config.template(:body), @config.template(:error))
      values["wiki_title"]      = "Error - #{@config.title}"
      values["name"]            = error[:name]
      values["backtrace"]       = error[:backtrace]
      values["backtrace_email"] = error[:backtrace].gsub(/<br \/>/, '')
      values["webmaster"]       = @config.webmaster
    end

    template.write_html_on(@rendered_page, values)
  end

    # Outputs the page.
  def output
    @response.add_header("Content-type", "text/html")
    @response.write_headers
    @response << @rendered_page
  end
end
