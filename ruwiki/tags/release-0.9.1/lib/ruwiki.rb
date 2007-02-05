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
  VERSION         = '0.9.1'
  CONTENT_VERSION = 2
end

require 'cgi'
require 'ruwiki/handler'
require 'ruwiki/auth'
require 'ruwiki/template'
require 'ruwiki/lang/en' # Default to the English language.
require 'ruwiki/config'
require 'ruwiki/backend'
require 'ruwiki/wiki'
require 'ruwiki/page'

  # = Ruwiki
  # Ruwiki is a simple, extensible Wiki written in Ruby. It supports both
  # CGI and WEBrick interfaces, templates, and CSS formatting. Additionally,
  # it supports project namespaces, so that two pages can be named the same
  # for differing projects without colliding or having to resort to odd
  # naming conventions. Please see the ::Ruwiki project in the running Wiki
  # for more information. Ruwiki 0.9.1 has German and Spanish translations
  # available.
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
    self.config!
  end

  def config!
    @markup.default_project = @config.default_project
    @markup.message = self.message
  end

  def load_config(filename)
    @config = Ruwiki::Config.read(filename)
    self.config!
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
      # Load the blacklists here because I don't as of yet know where else
      # to put them. :(
    @banned_agents    = load_blacklist('agents.banned')
    @banned_hostip    = load_blacklist('hostip.banned')
    @readonly_agents  = load_blacklist('agents.readonly')
    @readonly_hostip  = load_blacklist('hostip.readonly')
      # Prevent Google redirection against these URIs.
    Ruwiki::Wiki.no_redirect = load_blacklist('clean.uri')
  end

  def load_blacklist(filename)
    data = []
    filename = File.join(@config.storage_options[@config.storage_type]['data-path'], filename)
    ii = '^'
    jj = /^#{ii}/o
    File.open(filename, 'rb') do |f|
      f.each do |line|
        line.gsub!(%r{^\s*#.*$}, '')
        line.strip!
        if line.empty?
          data << nil
        else
          if line =~ jj
            data << "(?:#{line}\n)"
          else
            data << line
          end
        end
      end
    end
    data.compact!
    if data.empty?
      nil
    else
      Regexp.new(data.join("|"), Regexp::EXTENDED)
    end
  rescue
    return nil
  end

  def check_useragent
    addr = @request.environment['REMOTE_ADDR']
    user = @request.environment['HTTP_USER_AGENT']

    if user.nil? or user.empty?
      :forbidden
    elsif @banned_hostip and addr and addr =~ @banned_hostip
      :forbidden
    elsif @banned_agents and user =~ @banned_agents
      :forbidden
    elsif @readonly_hostip and addr and addr =~ @readonly_hostip
      :read_only
    elsif @readonly_agents and user =~ @readonly_agents
      :read_only
    else
      :clean
    end
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

  PROJECT_LIST_ITEM = %[%1$s (a href='\\%2$s/%1$s/_topics' class='rw_minilink')%3$s\\</a\\>]

    # Processes the page through the necessary steps. This is where the edit,
    # save, cancel, and display actions are present.
  def process_page
    content   = nil
    formatted = false

    @page     = Ruwiki::Page.new(@backend.retrieve(@topic, @project))
    @type     = :content

    agent_ok = check_useragent
    case agent_ok
    when :read_only
      @page.editable = false
      case @action
      when 'edit', 'save', 'preview', 'cancel', 'search'
        @page.indexable = false
      end
    when :forbidden
      forbidden
      return
    else
      unless @config.auth_mechanism.nil?
        @auth_token     = Ruwiki::Auth[@config.auth_mechanism].authenticate(@request, @response, @config.auth_options)
        @page.editable  = @auth_token.permissions['edit']
      end
    end

      # TODO Detect if @action has already been set.
    @action ||= @request.parameters['action'].downcase if @request.parameters['action']
    @action ||= 'save' if @request.parameters['save']
    @action ||= 'cancel' if @request.parameters['cancel']
    @action ||= 'preview' if @request.parameters['preview']

    unless @page.editable
      case @action
      when 'edit', 'save', 'preview', 'cancel'
        @action = 'show'
      end
    end

    case @action
    when 'search'
        # get, validate, and cleanse the search string
        # TODO: add empty string rejection.
      srchstr = validate_search_string(@request.parameters['q'])
      if not srchstr.nil?
        srchall = @request.parameters['a']

        @page.editable  = false
        @page.indexable = false

        @page.content = self.message[:search_results_for] % [srchstr]
        @page.topic = srchstr || ""

        unless srchall.nil?
        hits = @backend.search_all_projects(srchstr)
        else
          hits = @backend.search_project(@page.project, srchstr)
        end

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
      else
        @sysmessage = self.message[:no_empty_search_string] % [ @page.project, @page.topic ]
        @type = :content
      end
    when 'topics'
      if @backend.project_exists?(@page.project)
        topic_list = @backend.list_topics(@page.project)
      else
        topic_list = []
      end

      @page.editable = false

        # todo: make this localized
      if topic_list.empty?
        @page.content = self.message[:no_topics] % [@page.project]
      else
        topic_list.map! do |tt|
          uu = CGI.unescape(tt)
          if (uu != tt) or (tt !~ Ruwiki::Wiki::RE_WIKI_WORDS)
            "[[#{CGI.unescape(tt)}]]"
          else
            tt
          end
        end
        @page.content = <<EPAGE
= #{self.message[:topics_for_project] % [@page.project]}
* #{topic_list.join("\n* ")}
EPAGE
      end

      @type = :content
    when 'projects'
      proj_list = @backend.list_projects

      @page.editable = false

      if proj_list.empty?
        @page.content = self.message[:no_projects]
      else
          # TODO make this localized
        proj_list.map! { |proj| PROJECT_LIST_ITEM % [ proj, @request.script_url, self.message[:project_topics_link] ] }
        @page.content = <<EPAGE
= #{self.message[:wiki_projects] % [@config.title]}
* ::#{proj_list.join("\n* ::")}
EPAGE
      end

      content = @page.to_html(@markup)
      content.gsub!(%r{\(a href='([^']+)/_topics' class='rw_minilink'\)}, '<a href="\1/_topics" class="rw_minilink">') #'
      content.gsub!(%r{\\&lt;}, '<')
      content.gsub!(%r{\\&gt;}, '>')
      formatted = true
      @type = :content
    when 'edit', 'create'
        # Automatically create the project if it doesn't exist or if the
        # action is 'create'.
      @backend.create_project(@page.project) if @action == 'create'
      @backend.create_project(@page.project) unless @backend.project_exists?(@page.project)
      @page.creator = @auth_token.name if @action == 'create' and @auth_token
      @page.indexable = false
      @lock = @backend.obtain_lock(@page, @request.environment['REMOTE_ADDR']) rescue nil

      if @lock.nil?
        @type = :content
        @sysmessage = self.message[:page_is_locked]
      else
        content = nil
        formatted = true
        @type = :edit
      end
    when 'save', 'preview'
      np = @request.parameters['newpage'].gsub(/\r/, '').chomp
      @page.topic = @request.parameters['topic']
      @page.project = @request.parameters['project']
      @page.editor_ip = @request.environment['REMOTE_ADDR']
      @page.indexable = false

      save_ver = @backend.retrieve(@page.topic, @page.project)['properties']['version'].to_i
      sent_ver = @request.parameters['version'].to_i

      if sent_ver < save_ver
        @type = :edit

        np = np.split($/)
        content_diff = Diff::LCS.sdiff(np, @page.content.split($/), Diff::LCS::ContextDiffCallbacks)
        content_diff.reverse_each do |hunk|
          case hunk
          when Array
            hunk.reverse_each do |diff|
              case diff.action
              when '+'
#               np.insert(diff.old_position, "+#{diff.new_element}")
                np.insert(diff.old_position, "#{diff.new_element}")
              when '-'
                np.delete_at(diff.old_position)
#               np[diff.old_position] = "-#{diff.old_element}"
              when '!'
                np[diff.old_position] = "-#{diff.old_element}"
                np.insert(diff.old_position + 1, "+#{diff.new_element}")
              end
            end
          when Diff::LCS::ContextChange
            case hunk.action
            when '+'
              np.insert(hunk.old_position, "#{hunk.new_element}")
#             np.insert(hunk.old_position, "+#{hunk.new_element}")
            when '-'
              np.delete_at(hunk.old_position)
#             np[diff.old_position] = "-#{hunk.old_element}"
            when '!'
              np[hunk.old_position] = "-#{hunk.old_element}"
              np.insert(hunk.old_position + 1, "+#{hunk.new_element}")
            end
          end
        end
        @page.content = np.join("\n")

        edc = @request.parameters['edcomment']
        unless (edc.nil? or edc.empty? or edc == "*")
          @page.edit_comment = edc
        end

        @sysmessage = self.message[:not_editing_current_version] % [ @page.project, @page.topic ]
      else
        if @action == 'save'
          @page.editor = @auth_token.name if @auth_token
          op = @page.content
        else
          op = nil
        end

        if (np == op) and (@action == 'save')
          @type = :content
        else
          @page.content = np
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
            @lock = @backend.obtain_lock(@page, @request.environment['REMOTE_ADDR'])
            content = nil
            formatted = true
          end
        end
      end
    when 'cancel'
#     @page.topic       = @request.parameters['topic']
#     @page.project     = @request.parameters['project']
#     @page.version     = @request.parameters['version'].to_i

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
        :name => Ruwiki.clean_entities(args[1].inspect),
        :backtrace => args[1].backtrace.join("<br />\n")
      }
      @page = Ruwiki::Page.new(Ruwiki::Page::NULL_PAGE)
    end

    @rendered_page = ""
    values = {
      "css_link"  => @config.css_link,
      "home_link" => %Q(<a href="#{@request.script_url}">#{@config.title}</a>),
      "cgi_url"   => @request.script_url,
      "content"   => @content,
    }

    if @page.nil?
      values["page_project"]    = ""
      values["page_raw_topic"]  = ""
      values["page_topic"]      = ""
      values["editable"]        = false
      values["indexable"]       = false
    else
      values["page_project"]    = @page.project
      values["page_raw_topic"]  = @page.topic
      values["page_topic"]      = CGI.unescape(@page.topic)
      values["editable"]        = @page.editable
      values["indexable"]       = @page.indexable
    end

    values["url_project"]       = %Q(#{values["cgi_url"]}/#{values["page_project"]})
    values["url_topic_search"]  = %Q(#{values["url_project"]}/_search?q=#{values["page_topic"]})
    values["link_topic_search"] = %Q(<a href='#{values["url_topic_search"]}'><strong>#{values["page_topic"]}</strong></a>)
    values["message"]           = @sysmessage unless @sysmessage.nil?

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

    template.to_html(values, :messages => @config.message,
                             :output => @rendered_page)
  end

    # Outputs the page.
  def output
    return if @response.written?
#   if @request.environment["HTTP_ACCEPT"] =~ %r{application/xhtml\+xml}
#     @response.add_header("Content-type", "application/xhtml+xml")
#   else
      @response.add_header("Content-type", "text/html")
#   end
    @response.add_header("Cache-Control", "max_age=0")
    @response.write_headers
    @response << @rendered_page
  end

  def forbidden
    protocol = @request.environment["SERVER_PROTOCOL"] || "HTTP/1.0"
    @response.write_status "#{protocol} 403 FORBIDDEN\nDate: #{CGI::rfc1123_date(Time.now)}\n\n"
  end

    # nil if string is invalid
  def validate_search_string(instr)
    return nil if instr.empty?

    modstr = instr.dup

      #TODO: add validation of modstr
    return modstr
  end

  def self.clean_entities(data)
    data.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')
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
