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
require 'digest/md5'
require 'ruwiki/handler'
require 'ruwiki/template'
require 'ruwiki/lang/en' # Default to the English language.
require 'ruwiki/config'
require 'ruwiki/backend'
require 'ruwiki/wiki'
require 'ruwiki/page'

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
  #   http://domain.com/ruwiki.cgi?topic=PageName&project=Project
  #   http://domain.com/ruwiki.cgi/PageName
  #   http://domain.com/ruwiki.cgi/Project/
  #   http://domain.com/ruwiki.cgi/Project/PageName
  #
  # Copyright:: Copyright © 2003 - 2003, Digikata and HaloStatue, Ltd.
  # Authors::   Alan Chen (alan@digikata.com)
  #             Austin Ziegler (ruwiki@halostatue.ca)
  # Licence::   Ruby's
class Ruwiki
  VERSION         = '0.6.2.0'

  ALLOWED_ACTIONS = %w(edit create)
  EDIT_ACTIONS    = %w(save cancel)
  EDIT_VARS       = %w(newpage origpage topic project old_version version)
  RESERVED        = ['action', EDIT_VARS].flatten

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
    raise message()[:config_not_ruwiki_config] unless c.kind_of?(Ruwiki::Config)
    @config = c
    @markup.default_project = @config.default_project
  end

    # The message hash.
  def message
    @config.message
  end

    # Initializes Ruwiki.
  def initialize(handler)
    @request    = handler.request
    @response   = handler.response

    @config     = Ruwiki::Config.new

    @path_info  = @request.determine_request_path || ""

    @type       = nil
    @error      = {}

    @markup     = Ruwiki::Wiki.new(@config.default_project,
                                   @request.script_url)
  end

    # Initializes the backend for Ruwiki.
  def set_backend
    @backend = BackendDelegator.new(self, @config.storage_type)
    @markup.backend = @backend
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
    path_info = @path_info.split(%r{/}, -1).map { |e| e.empty? ? nil : e }

    if path_info.size == 1 or (path_info.size > 1 and path_info[0])
      raise message()[:invalid_path_info_value] % [@path_info] unless path_info[0].nil?
    end

      # path_info[0] will ALWAYS be nil.
    path_info.shift

    case path_info.size
    when 0 # Safety check.
      nil
    when 1 # /PageTopic OR /_edit
      set_page_name_or_action(path_info[0])
    when 2 # /Project/ OR /Project/PageTopic OR /Project/_edit OR /Project/create
      @project = path_info.shift
      set_page_name_or_action(path_info[0])
    else # /Project/PageTopic/_edit OR /Project/diff/3,4 OR something else.
      @project = path_info.shift
      item = path_info.shift
      action = RE_ACTION.match(item)
      if action
        @action = action.captures[0]
        @params = path_info
      else
        @topic = item
        item = path_info.shift
        action = RE_ACTION.match(item)
        if action
          @action = action.captures[0]
          @params = path_info
        end
      end
    end

    @request.each_parameter do |key, val|
      next if RESERVED.include?(key)
      @topic = key
    end

    @project ||= @request.parameters['project']
    @project ||= @config.default_project
    @topic    ||= @config.default_page
  end

    # Processes the page through the necessary steps. This is where the edit,
    # save, cancel, and display actions are present.
  def process_page
    content   = nil
    page_init = @backend.retrieve(@topic, @project)

    page_init[:markup]        = @markup
    page_init[:project]     ||= @config.default_project
    page_init[:remote_host]   = @request.environment['REMOTE_HOST']
    page_init[:remote_addr]   = @request.environment['REMOTE_ADDR']

    @page     = Ruwiki::Page.new(page_init)

    @type     = :content

      # TODO Detect if @action has already been set.
    @action = @request.parameters['action'].downcase if @request.parameters['action']

    if @action
      case @action
      when 'edit', 'create'
          # Automatically create the project if it doesn't exist or if the
          # action is 'create'.
        @backend.create_project(@page.project) if @action == 'create'
        @backend.create_project(@page.project) unless @backend.project_exists?(@page.project)
        @backend.obtain_lock(@page, @request.environment['REMOTE_ADDR'])

        content = nil
        @type = :edit
      when 'save'
        np = @request.parameters['newpage'].gsub(/\r/, "").chomp
        @page.topic = @request.parameters['topic']
        @page.project = @request.parameters['project']

        op = @request.parameters['origpage'].unpack("m*")[0]

        if np == op
          @page.content = op
          @type = :content
        else
          @page.content = np
          @page.old_version = @request.parameters['old_version'].to_i + 1
          @page.version = @request.parameters['version'].to_i + 1
          @type = :save
          @backend.store(@page)
        end
        @backend.release_lock(@page, @request.environment['REMOTE_ADDR'])

        content = @page.to_html
      when 'cancel'
        @page.topic       = @request.parameters['topic']
        @page.project     = @request.parameters['project']
        @page.content     = @request.parameters['origpage'].unpack("m*")[0]
        @page.old_version = @request.parameters['old_version'].to_i
        @page.version     = @request.parameters['version'].to_i

        content           = @page.to_html
        @backend.release_lock(@page, @request.environment['REMOTE_ADDR'])
      else
        # TODO Return a 501 Not Implemented error
        nil
      end
    else
      content = @page.to_html
    end
  rescue Exception => e
    @type = :error
    if e.kind_of?(Ruwiki::Backend::BackendError)
      @error[:name] = "#{message()[:error]}: #{e.to_s}"
    else
      @error[:name] = "#{message()[:complete_utter_failure]}: #{e.to_s}"
    end
    @error[:backtrace] = e.backtrace.join("<br />\n")
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
      raise ArgumentError, message()[:render_arguments] unless args.size == 2
      type  = args[0]
      error = {}
      error[:name] = args[1].inspect.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')
      error[:backtrace] = args[1].backtrace.join("<br />\n")
    end

    @rendered_page = ""
    values = { "css_link"   => @config.css_link,
               "home_link"  => %Q(<a href="#{@request.script_url}">#{@config.title}</a>),
               "encoding"   => @config.message[:encoding]
             }

    case type
    when :content, :save
      values["wiki_title"]      = "#{message()[:error]} - #{@config.title}" if @page.nil?
      values["wiki_title"]    ||= "#{@page.project}::#{CGI.unescape(@page.topic)} - #{@config.title}"
      values["page_topic"]      = CGI.unescape(@page.topic)
      values["page_raw_topic"]  = @page.topic
      values["page_project"]    = @page.project
      values["cgi_url"]         = @request.script_url
      values["content"]         = @content
      if type == :content
        template = TemplatePage.new(@config.template(:body), @config.template(:content), @config.template(:controls))
      else
        template = TemplatePage.new(@config.template(:body), @config.template(:save), @config.template(:controls))
      end
    when :edit
      template = TemplatePage.new(@config.template(:body), @config.template(:edit))
      values["wiki_title"]            = "#{message()[:editing]}: #{@page.project}::#{CGI.unescape(@page.topic)} - #{@config.title}"
      values["page_topic"]            = CGI.unescape(@page.topic)
      values["page_raw_topic"]        = @page.topic
      values["page_project"]          = @page.project
      values["cgi_url"]               = @request.script_url
      values["page_content"]          = @page.content
      values["orig_page"]             = [@page.content].pack("m*")
      values["page_old_version"]      = @page.old_version.to_s
      values["page_version"]          = @page.version.to_s
      values["unedited_page_content"] = @page.to_html
      values["pre_page_content"]      = CGI.escapeHTML(@page.content)
    when :error
      template = TemplatePage.new(@config.template(:body), @config.template(:error))
      values["wiki_title"]      = "#{message()[:error]} - #{@config.title}"
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
    @response.add_header("Cache-Control", "max_age=0")
    @response.write_headers
    @response << @rendered_page
  end

private
  RE_ACTION = %r{^_([[:lower:]]+)$}

  def set_page_name_or_action(item)
    action = RE_ACTION.match(item)
    if action
      @action     = action.captures[0]
    else
      @topic  = item
    end
  end
end
