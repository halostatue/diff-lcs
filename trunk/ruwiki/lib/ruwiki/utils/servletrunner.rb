#!/usr/bin/env ruby
#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# This file may be renamed to change the URI for the wiki.
#
# $Id$
#++

  # Customize this if you put the RuWiki files in a different location.
require 'webrick'

require 'ruwiki/utils'
require 'ruwiki/exportable'
require 'ruwiki/servlet'
require 'ruwiki/lang/en'
require 'ruwiki/lang/de'
require 'ruwiki/lang/es'

require 'optparse'
require 'ostruct'

module Ruwiki::Utils::ServletRunner
  COPYRIGHT = <<-"COPYRIGHT"
Ruwiki #{Ruwiki::VERSION}
  Copyright © 2002 - 2004, Digikata and HaloStatue

  http://rubyforge.org/projects/ruwiki/

  Alan Chen (alan@digikata.com)
  Austin Ziegler (ruwiki@halostatue.ca)

Licensed under the same terms as Ruby.

$Id$
COPYRIGHT

  class WEBrickConfig
    include Ruwiki::Exportable

    exportable_group 'webrick-config'
    attr_accessor :port
    exportable    :port
    attr_accessor :addresses
    exportable    :addresses
    attr_accessor :mount
    exportable    :mount
    attr_accessor :do_log
    exportable    :do_log
    attr_accessor :log_dest
    exportable    :log_dest
    attr_accessor :threads
    exportable    :threads

    def export
      hash = super
      sc = hash['webrick-config']
      sc['addresses'] = sc['addresses'].join(";")
      sc['do-log']    = (sc['do-log'] ? 'true' : 'false')
      hash
    end

      # Because the servlet can be started from the command-line, provide
      # defaults for all possible configuration options.
    def initialize(exported = {})
      sc = exported['webrick-config'] || {}
      @port         = sc['port']      || 8808
      @mount        = sc['mount']     || '/'
      @addresses    = sc['addresses']
      @do_log       = ((sc['do-log'] == 'false') ? false : true)
      @log_dest     = sc['log-dest']
      @threads      = sc['threads']   || 1

      if @addresses.nil? or @addresses.empty?
        @addresses  = []
      else
        @addresses  = @addresses.split(/;/)
      end

      if @log_dest.nil? or @log_dest.empty?
        @log_dest   = "<STDERR>"
      end
    end
  end

  def self.message=(lang)
    if lang.kind_of?(Hash)
      @message = lang
    elsif "constant" == defined?(lang::Message)
      @message = lang::Message
    else
      raise ArgumentError
    end
  end
  def self.message(id)
    @message[id]
  end

  class << self
      # This is for the WEBrick version of Ruwiki. This has been abstracted to
      # accept a Config global variable to reconfigure Ruwiki after initial
      # creation.
    def read_config(filename)
      ch = {}
      if File.exists?(filename)
        File.open(filename, 'rb') { |ff| ch = Ruwiki::Exportable.load(ff.read) }
      end

      @sc = WEBrickConfig.new(ch)
      @rc = Ruwiki::Config.new(ch)

      if @rc.webmaster.nil? or @rc.webmaster.empty?
        @rc.webmaster = "webmaster@domain.tld"
      end
    end

    def run(argv, input = $stdin, output = $stdout, error = $stderr)
      read_config(Ruwiki::Config::CONFIG_NAME)

      save_config = nil

      language = 'en'
      find_lang = argv.grep(%r{^--language})
      find_lang.each do |ee|
        if ee =~ %r{^--language=}
          language = ee.sub(%r{^--language=}, '')
        else
          language = argv[argv.index(ee).succ]
        end
      end

      require "ruwiki/lang/#{language.downcase}"
      @rc.language = Ruwiki::Lang.const_get(language.upcase)
      self.message = @rc.language

      argv.options do |oo|
        oo.banner = self.message(:runner_usage) % [ File.basename($0) ]
        oo.separator self.message(:runner_general_options)
        oo.on('--save-config [FILENAME]', *([ self.message(:runner_saveconfig_desc), Ruwiki::Config::CONFIG_NAME ].flatten)) { |fname|
          save_config = fname || Ruwiki::Config::CONFIG_NAME
        }
        oo.on('--config FILENAME', *self.message(:runner_config_desc)) { |fn|
          read_config(fn)
        }
        oo.separator ""
        oo.separator self.message(:runner_webrick_options)
        oo.on('-P', '--port PORT', Numeric, *self.message(:runner_port_desc)) { |port|
          @sc.port = port
        }
        oo.on('-A', '--accept ADDRESS,ADDRESS,ADDRESS', Array, *self.message(:runner_address_desc)) { |address|
          @sc.addresses += address
        }
        oo.on('-L', '--local', *self.message(:runner_local_desc)) {
          @sc.addresses = ["127.0.0.1"]
        }
        oo.on('-M', '--mount MOUNT-POINT', *self.message(:runner_mountpoint_desc)) { |mp|
          @sc.mount = mp
        }
        oo.on('--[no-]log', *self.message(:runner_log_desc)) { |log|
          @sc.do_log = log
        }
        oo.on('--logfile LOGFILE', *self.message(:runner_logfile_desc)) { |lf|
          @sc.log_dest = lf
        }
        oo.on('-T', '--threads THREADS', Integer, *self.message(:runner_threads_desc)) { |tc|
          @sc.threads = tc
        }
        oo.separator ""
        oo.separator self.message(:runner_ruwiki_options)
        oo.on('--language=LANGUAGE', *self.message(:runner_language_desc)) { |lang|
          nil
        }
        oo.on('--webmaster WEBMASTER', *self.message(:runner_webmaster_desc)) { |wm|
          @rc.webmaster = wm
        }
        oo.on('--[no-]debug', *self.message(:runner_debug_desc)) { |dd|
          @rc.debug = dd
        }
        oo.on('--title TITLE', *self.message(:runner_title_desc)) { |tt|
          @rc.title = tt
        }
        oo.on('--default-page PAGENAME', *self.message(:runner_defaultpage_desc)) { |dp|
          @rc.default_page = dp
        }
        oo.on('--default-project PAGENAME', *self.message(:runner_defaultproject_desc)) { |dp|
          @rc.default_project = dp
        }
        oo.on('--template-path TEMPLATE_PATH', *self.message(:runner_templatepath_desc)) { |tp|
          @rc.template_path = tp
        }
        oo.on('--templates TEMPLATES', *self.message(:runner_templatename_desc)) { |tp|
          @rc.template_set = tp
        }
        oo.on('--css CSS_NAME', *self.message(:runner_cssname_desc)) { |css|
          @rc.css = css
        }
        oo.on('--storage-type TYPE', Ruwiki::KNOWN_BACKENDS, *([self.message(:runner_storage_desc), Ruwiki::KNOWN_BACKENDS.join(", ")].flatten)) { |st|
          @rc.storage_type = st
          @rc.storage_options[@rc.storage_type]['data-path'] ||= "./data/"
          @rc.storage_options[@rc.storage_type]['extension'] ||= "ruwiki"
        }
        oo.on('--data-path PATH', *self.message(:runner_datapath_desc)) { |fdp|
          @rc.storage_options['flatfiles']['data-path'] = fdp
        }
        oo.on('--extension EXT', *self.message(:runner_extension_desc)) { |ext|
          @rc.storage_options['flatfiles']['data-path'] = fdp
        }
        if defined?(Gem::Cache)
          oo.separator ""
          oo.on('--central', *self.message(:runner_central_desc)) {
            gempath = Gem::Cache.from_installed_gems.search("ruwiki", "=#{Ruwiki::VERSION}").last.full_gem_path
            @rc.storage_type    = 'flatfiles'
            @rc.storage_options['flatfiles']['data-path'] = "#{gempath}/data"
            @rc.storage_options['flatfiles']['extension'] = "ruwiki"
            @rc.storage_options['flatfiles']['format'] = "exportable"
            @rc.template_path   = "#{gempath}/templates"
            @rc.template_set    = "sidebar"
          }
        end

          # TODO: Add options for time, date, and datetime formats.
        oo.separator ""
        oo.separator self.message(:runner_general_info)
        oo.on_tail('--help', *self.message(:runner_help_desc)) {
          error << oo << "\n"
          return 0
        }
        oo.on_tail('--version', *self.message(:runner_version_desc)) {
          error << COPYRIGHT << "\n"
          return 0
        }
        oo.parse!
      end

      if save_config
        sc = @sc.export
        rc = @rc.export
        cf = sc.merge(rc)

        File.open(save_config, 'wb') { |ff| ff.puts Ruwiki::Exportable.dump(cf) }
        return 0
      end

        # If the list of accepted addresses is not empty, provide IP-based
        # restrictions.
      if not @sc.addresses.empty?
        localonly = lambda do |sock|
          if not @sc.addresses.include?(sock.peeraddr[3])
            raise WEBrick::ServerError, self.message(:runner_rejected_address) % [ sock.peeraddr[3], @sc.addresses.join(", ") ]
          end
        end
      else
        localonly = nil
      end

      if @sc.do_log
        if "<STDERR>" == @sc.log_dest
          dest = $stderr
        else
          dest = File.open(@sc.log_dest, "wb+")
        end
        logger = WEBrick::Log.new(dest, WEBrick::Log::DEBUG)
      else
        logger = nil
      end

      banner = self.message(:runner_banner) %
        [ Ruwiki::Utils::ServletRunner::COPYRIGHT, @sc.port,
          @sc.addresses.join(", "), @sc.mount, @sc.do_log, @sc.log_dest,
          @sc.threads, @rc.webmaster, @rc.debug, @rc.title,
          @rc.default_project, @rc.default_page, @rc.template_path,
          @rc.template_set, @rc.css, @rc.storage_type,
          @rc.storage_options[@rc.storage_type]['data-path'],
          @rc.storage_options[@rc.storage_type]['extension'] ]

      banner.each { |bb| logger.info(bb) } unless logger.nil?

      server = WEBrick::HTTPServer.new(:Port            => @sc.port.to_i,
                                       :StartThreads    => @sc.threads.to_i,
                                       :AcceptCallback  => localonly,
                                       :Logger          => logger)
      @rc.logger = logger
      Ruwiki::Servlet.config = @rc

      server.mount(@sc.mount, Ruwiki::Servlet)
      trap("INT") { server.shutdown; return 0 }
      server.start
      return 0
    end
  end
end
