#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

class Ruwiki
  VERSION         = '0.8.0'
  CONTENT_VERSION = 2
end

require 'cgi'
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
  # conventions. Please see the ::Ruwiki project in the running Wiki for more
  # information. Ruwiki 0.7.0 has German and Spanish translations available.
  #
  # == Quick Start (CGI)
  # 1. Place the Ruwiki directory in a place that your webserver can execute
  #    CGI programs and ensure that ruwiki.cgi is executable on your webserver.
  # 2. Point your web browser to the appropriate URL.
  #
  # == Quick Start (WEBrick)
  # 1. Run ruwiki_servlet (ruwiki_servlet.bat under Windows).
  # 2. Point your web browser to <http://localhost:8808/>.
  #
  # == Configuration
  # There are extensive configuration options available. The Ruwiki WEBrick
  # servlet offers command-line options that simplify the configuration of
  # Ruwiki without editing the servlet; use ruwiki_servlet --help for more
  # information.
  #
  # == Copyright
  # Copyright:: Copyright © 2002 - 2004, Digikata and HaloStatue, Ltd.
  # Authors::   Alan Chen (alan@digikata.com)
  #             Austin Ziegler (ruwiki@halostatue.ca)
  # Licence::   Ruby's
class Ruwiki
  ALLOWED_ACTIONS = %w(edit create)
  EDIT_ACTIONS    = %w(save cancel)
  EDIT_VARS       = %w(newpage version edcomment q)
  RESERVED        = ['save', 'preview', 'cancel', EDIT_VARS].flatten

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
  def config=(cc)
    raise self.message[:config_not_ruwiki_config] unless cc.kind_of?(Ruwiki::Config)
    @config = cc
    @markup.default_project = @config.default_project
    @markup.message = self.message
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

    @path_info  = @request.determine_request_path || ''

    @type       = nil
    @error      = {}

    @markup     = Ruwiki::Wiki.new(@config.default_project,
                                   @request.script_url,
                                   @config.title)
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
  rescue Exception => ee
    render(:error, ee)
  ensure
    output
  end

    # Initializes current page for Ruwiki.
  def set_page
    path_info = @path_info.split(%r{/}, -1).map { |ee| ee.empty? ? nil : ee }

    if path_info.size == 1 or (path_info.size > 1 and path_info[0])
      raise self.message[:invalid_path_info_value] % [@path_info] unless path_info[0].nil?
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

#   @request.each_parameter { |key, val| puts "#{key} :: #{val.class}" }

    @project ||= @config.default_project
    @topic   ||= @config.default_page
  end

    # Processes the page through the necessary steps. This is where the edit,
    # save, cancel, and display actions are present.
  def process_page
    content   = nil
    formatted = false

    @page     = Ruwiki::Page.new(@backend.retrieve(@topic, @project))
    @type     = :content

      # TODO Detect if @action has already been set.
    @action ||= @request.parameters['action'].downcase if @request.parameters['action']
    @action ||= 'save' if @request.parameters['save']
    @action ||= 'cancel' if @request.parameters['cancel']
    @action ||= 'preview' if @request.parameters['preview']

    case @action
    when 'search'
        # todo: add global search checkbox
        # get, validate, and cleanse the search string
      srchstr = validate_search_string(@request.parameters['q'])
      srchall = @request.parameters['a']

      @page.content = self.message[:search_results_for] % [srchstr]
      @page.topic = srchstr

      unless srchall.nil?
        hits = @backend.search_all_projects(srchstr)
      else
        hits = @backend.search_project(@page.project, srchstr)
      end

        # debug hit returns
#     hits.each { |key, val| $stderr << "  #{key} : #{val}\n" }

        # turn hit hash into content
      hitarr = []
        # organize by number of hits
      hits.each { |key, val| (hitarr[val] ||= []) << key }

      rhitarr = hitarr.reverse
      maxhits = hitarr.size
      rhitarr.each_with_index do |tarray, rnhits|
        next if tarray.nil? or tarray.empty?
        nhits = maxhits - rnhits - 1

        if nhits > 0
          @page.content << "\n== #{self.message[:number_of_hits] % [nhits]}\n* "
          @page.content << tarray.join("\n* ")
        end
      end

      @type = :search
    when 'topics'
      if @backend.project_exists?(@page.project)
        topic_list = @backend.list_topics(@page.project)
      else
        topic_list = []
      end

        # todo: make this localized
      if topic_list.empty?
        @page.content = self.message[:no_topics] % [@page.project]
      else
        topic_list.map! do |tt|
          uu = CGI.unescape(tt)
          if (uu != tt) or (tt =~ /^[A-Z][a-z]+$/)
            "[[#{CGI.unescape(tt)}]]"
          else
            tt
          end
        end
        @page.content = <<EPAGE
= #{self.message[:topics_for_project] % [@page.project]}
* #{topic_list.join("\n* ")}
EPAGE
$stderr.puts @page.content.inspect
      end

      @type = :content
    when 'projects'
      proj_list = @backend.list_projects

      if proj_list.empty?
        @page.content = self.message[:no_projects]
      else
          # TODO make this localized
        proj_list.map! { |proj| %[#{proj} (a href='\\#{@request.script_url}/#{proj}/_topics' class='rw_minilink')#{self.message[:project_topics_link]}</a>] }
        @page.content = <<EPAGE
= #{self.message[:wiki_projects] % [@config.title]}
* ::#{proj_list.join("\n* ::")}
EPAGE
      end

      content = @page.to_html(@markup)
      content.gsub!(%r{\(a href='([^']+)/_topics' class='rw_minilink'\)}, '<a href="\1/_topics" class="rw_minilink">') #'
      formatted = true
      @type = :content
    when 'edit', 'create'
        # Automatically create the project if it doesn't exist or if the action
        # is 'create'.
      @backend.create_project(@page.project) if @action == 'create'
      @backend.create_project(@page.project) unless @backend.project_exists?(@page.project)
      @backend.obtain_lock(@page, @request.environment['REMOTE_ADDR'])

      content = nil
      formatted = true
      @type = :edit
    when 'save', 'preview'
      np = @request.parameters['newpage'].gsub(/\r/, '').chomp
      @page.topic = @request.parameters['topic']
      @page.project = @request.parameters['project']
      @page.editor_ip = @request.environment['REMOTE_ADDR']

      if @action == 'save'
        op = @page.content
      else
        op = nil
      end

      if np == op and @action == 'save'
        @page.content = op
        @type = :content
      else
        @page.content      = np
        edc = @request.parameters['edcomment']
        unless (edc.nil? or edc.empty? or edc == "*")
          @page.edit_comment = edc
        end

        if @action == 'save'
          @type = :save
          @page.version = @request.parameters['version'].to_i + 1
          @backend.store(@page)
        
            # hack to ensure that Recent Changes are updated correctly
          if @page.topic == 'RecentChanges'
            recent = Ruwiki::Page.new(@backend.retrieve(@page.topic, @page.project))
            @page.content = recent.content
          end

          @backend.release_lock(@page, @request.environment['REMOTE_ADDR'])
        else
          @type = :preview
          content = nil
          formatted = true
        end
      end
    when 'cancel'
      @page.topic       = @request.parameters['topic']
      @page.project     = @request.parameters['project']
      @page.version     = @request.parameters['version'].to_i

      @backend.release_lock(@page, @request.environment['REMOTE_ADDR'])
      @type = :content
    else
        # TODO AZ: This should probably return a 501 Not Implemented or some
        # other error unless @action.nil?
      nil
    end
    content = @page.to_html(@markup) if not formatted
  rescue Exception => ee  # rescue for def process_page
    @type = :error
    if ee.kind_of?(Ruwiki::Backend::BackendError)
      name = "#{self.message[:error]}: #{ee.to_s}"
    else
      name = "#{self.message[:complete_utter_failure]}: #{ee.to_s}"
    end
    @error[:name] = CGI.escapeHTML(name)
    @error[:backtrace] = ee.backtrace.map { |el| CGI.escapeHTML(el) }.join("<br />\n")
    content = nil
  ensure
    @content = content
  end  # def process_page

    # Renders the page.
  def render(*args)
    if args.empty?
      type  = @type
      error = @error
    else
      raise ArgumentError, self.message[:render_arguments] unless args.size == 2
      type  = args[0]
      error = {
        :name => args[1].inspect.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;'),
        :backtrace => args[1].backtrace.join("<br />\n")
      }
      @page = Ruwiki::Page.new(Ruwiki::Page::NULL_PAGE)
    end

    @rendered_page = ""
    values = {
      "css_link"  => @config.css_link,
      "home_link" => %Q(<a href="#{@request.script_url}">#{@config.title}</a>),
      "editable"  => @page.editable,
      "indexable" => @page.indexable,
      "cgi_url"   => @request.script_url,
      "content"   => @content,
    }

    if @page.nil?
      values["page_project"]    = ""
      values["page_raw_topic"]  = ""
      values["page_topic"]      = ""
    else
      values["page_project"]    = @page.project
      values["page_raw_topic"]  = @page.topic
      values["page_topic"]      = CGI.unescape(@page.topic)
    end

    values["url_project"]       = %Q(#{values["cgi_url"]}/#{values["page_project"]})
    values["url_topic_search"]  = %Q(#{values["url_project"]}/_search?q=#{values["page_topic"]})
    values["link_topic_search"] = %Q(<a href='#{values["url_topic_search"]}'><strong>#{values["page_topic"]}</strong></a>)

    case type
    when :content, :save, :search
      values["wiki_title"]              = "#{self.message[:error]} - #{@config.title}" if @page.nil?
      values["wiki_title"]            ||= "#{@page.project}::#{CGI.unescape(@page.topic)} - #{@config.title}"
      values["label_topic_or_search"]   = self.message[:label_topic]
      values["page_topic_name"]         = values["page_topic"]
      if type == :content or type == :search
        template = TemplatePage.new(@config.template(:body), @config.template(:content), @config.template(:controls), @config.template(:footer))
        if type == :search
          values["label_topic_or_search"] = self.message[:label_search]
        else
          values["page_topic"] = values["link_topic_search"]
        end
      else
          # action type was save
        values["page_topic"] = values["link_topic_search"]
        template = TemplatePage.new(@config.template(:body), @config.template(:save), @config.template(:controls), @config.template(:footer))
      end
    when :edit, :preview
      template = TemplatePage.new(@config.template(:body), @config.template(:edit))
      values["wiki_title"]            = "#{self.message[:editing]}: #{@page.project}::#{CGI.unescape(@page.topic)} - #{@config.title}"
      values["page_content"]          = @page.content
      values["page_version"]          = @page.version.to_s
      values["unedited_page_content"] = @page.to_html(@markup)
      values["pre_page_content"]      = CGI.escapeHTML(@page.content)
      if @request.parameters["edcomment"].nil? or @request.parameters["edcomment"].empty?
        values["edit_comment"] = "*"
      else
        values["edit_comment"] = @request.parameters["edcomment"]
      end
    when :error
      template = TemplatePage.new(@config.template(:body), @config.template(:error))
      values["wiki_title"]      = "#{self.message[:error]} - #{@config.title}"
      values["name"]            = error[:name]
      values["backtrace"]       = error[:backtrace]
      values["backtrace_email"] = error[:backtrace].gsub(/<br \/>/, '')
      values["webmaster"]       = @config.webmaster
    end

    template.process(@rendered_page, values, @config.message)
  end

    # Outputs the page.
  def output
    @response.add_header("Content-type", "text/html")
    @response.add_header("Cache-Control", "max_age=0")
    @response.write_headers
    @response << @rendered_page
  end

    # nil if string is invalid
  def validate_search_string(instr)
    return nil if instr.empty?

    modstr = instr.dup

      #TODO: add validation of modstr
    return modstr
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
