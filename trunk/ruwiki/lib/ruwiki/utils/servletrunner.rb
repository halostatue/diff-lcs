#!/usr/bin/env ruby

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

  class << self
      # This is for the WEBrick version of Ruwiki. This has been abstracted to
      # accept a Config global variable to reconfigure Ruwiki after initial
      # creation.
    def read_config(filename)
      ch = {}
      if File.exists?(filename)
        File.open(filename, 'rb') do |ff|
          ch = Ruwiki::Exportable.load(ff.read)
        end
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

      argv.options do |o|
        o.banner = "Usage: #{File.basename($0)} [options]"
        o.separator "General options:"
        o.on('--save-config [FILENAME]', 'Save the configuration to FILENAME and', 'exit. If FILENAME is not used, then', "#{Ruwiki::Config::CONFIG_NAME} will be used. All options", 'will be read, stored, and saved. The', 'servlet will not start.') { |fname| 
          save_config = fname || Ruwiki::Config::CONFIG_NAME
        }
        o.on('--config FILENAME', 'Read the default configuration from', "FILENAME instead of #{Ruwiki::Config::CONFIG_NAME}.", 'Options set until this point will be', 'reset to the values from the read', 'configuration file.') { |fn|
          read_config(fn)
        }
        o.separator ""
        o.separator "WEBrick options:"
        o.on('-P', '--port PORT', Numeric, 'Runs the Ruwiki servlet on the specified', 'port. Default 8808.') { |port|
          @sc.port = port
        }
        o.on('-A', '--accept ADDRESS,ADDRESS,ADDRESS', Array, 'Restricts the Ruwiki servlet to accepting', 'connections from the specified address or', '(comma-separated) addresses. May be', 'specified multiple times. Defaults to all', 'addresses.') { |address|
          @sc.addresses += address
        }
        o.on('-L', '--local', 'Restricts the Ruwiki servlet to accepting', 'only local connections (127.0.0.1).', 'Overrides any previous --accept addresses.') { |local|
          @sc.addresses = ["127.0.0.1"]
        }
        o.on('-M', '--mount MOUNT-POINT', 'The relative URI from which Ruwiki ', 'will be accessible. Defaults to "/".') { |mp|
          @sc.mount = mp
        }
        o.on('--[no-]log', 'Log WEBrick activity. Default is --log.') { |log|
          @sc.do_log = log
        }
        o.on('--logfile LOGFILE', 'The file to which WEBrick logs are', 'written. Default is standard error.') { |lf|
          @sc.log_dest = lf
        }
        o.on('-T', '--threads THREADS', Integer, 'Sets the WEBrick threadcount.') { |tc|
          @sc.threads = tc
        }
        o.separator ""
        o.separator "Ruwiki options:"
        o.on('--language LANGUAGE', 'The interface language for Ruwiki.', 'Defaults to "en". May be "en", "de", or', '"es".') { |lang|
          @rc.language = Ruwiki::Lang::const_get(lang.upcase)
        }
        o.on('--webmaster WEBMASTER', 'The Ruwiki webmaster email address.', 'Defaults to "webmaster@domain.tld".') { |wm|
          @rc.webmaster = wm
        }
        o.on('--[no-]debug', 'Turns on Ruwiki debugging. Defaults', 'to --no-debug.') { |d|
          @rc.debug = d
        }
        o.on('--title TITLE', 'Provides the Ruwiki title. Default is', '"Ruwiki".') { |t|
          @rc.title = t
        }
        o.on('--default-page PAGENAME', 'An alternate default page. Default is', '"ProjectIndex".') { |dp|
          @rc.default_page = dp
        }
        o.on('--default-project PAGENAME', 'An alternate default project. Default is', '"Default".') { |dp|
          @rc.default_project = dp
        }
        o.on('--template-path TEMPLATE_PATH', 'The location of Ruwiki templates. Default', 'is "./templates".') { |tp|
          @rc.template_path = tp
        }
        o.on('--templates TEMPLATES', 'The name of the Ruwiki templates. Default', 'is "default".') { |tp|
          @rc.template_set = tp
        }
        o.on('--css CSS_NAME', 'The name of the CSS file in the template', 'path. Default is "ruwiki.css".') { |css|
          @rc.css = css
        }
        o.on('--storage-type TYPE', Ruwiki::KNOWN_BACKENDS, 'Select the storage type:', "#{Ruwiki::KNOWN_BACKENDS.join(", ")}") { |st|
          @rc.storage_type = st
          @rc.storage_options[@rc.storage_type]['data-path'] ||= "./data/"
          @rc.storage_options[@rc.storage_type]['extension'] ||= "ruwiki"
        }
        o.on('--data-path PATH', 'The path where data files are stored.', 'Default is "./data".') { |fdp|
          @rc.storage_options[:flatfiles]['data-path'] = fdp
          @rc.storage_options[:yaml]['data-path'] = fdp
          @rc.storage_options[:marshal]['data-path'] = fdp
        }
        o.on('--extension EXT', 'The extension for data files.', 'Default is "ruwiki".') { |ext|
          @rc.storage_options[:flatfiles]['extension'] = ext
          @rc.storage_options[:yaml]['extension'] = ext
          @rc.storage_options[:marshal]['extension'] = ext
        }

        # TODO: Add options for time, date, and datetime formats.
        o.separator ""
        o.separator "General info:"
        o.on_tail('--help', 'Shows this text.') {
          error << o << "\n"
          return 0
        }
        o.on_tail('--version', 'Shows the version of Ruwiki.') {
          error << COPYRIGHT << "\n"
          return 0
        }
        o.parse!
      end

      if save_config
        sc = @sc.export
        rc = @rc.export
        cf = sc.merge(rc)

        File.open(save_config, 'wb') { |f| f.puts Ruwiki::Exportable.dump(cf) }
        return 0
      end

        # If the list of accepted addresses is not empty, provide IP-based
        # restrictions.
      if not @sc.addresses.empty?
        localonly = lambda do |sock|
          if not @sc.addresses.include?(sock.peeraddr[3])
            msg = "Rejected peer address #{sock.peeraddr[3]}. Connections are only accepted from: #{opts.addresses.join(", ")}."
            raise WEBrick::ServerError, msg
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

      banner = <<-"BANNER"
#{Ruwiki::Utils::ServletRunner::COPYRIGHT}

WEBrick options:
  Port                  #{@sc.port}
  Accepted Addresses    #{@sc.addresses.join(", ")}
  Mount Point           #{@sc.mount}
  Logging?              #{@sc.do_log}
  Log Destination       #{@sc.log_dest}
  Threads               #{@sc.threads}

Ruwiki options:
  Webmaster             #{@rc.webmaster}
  Debugging?            #{@rc.debug}
  Title                 #{@rc.title}
  Default Project       #{@rc.default_project}
  Default Page          #{@rc.default_page}
  Template Path         #{@rc.template_path}
  Template Set          #{@rc.template_set}
  CSS Source            #{@rc.css}

  Storage Type          #{@rc.storage_type}
  Data Path             #{@rc.storage_options[@rc.storage_type]['data-path']}
  Extension             #{@rc.storage_options[@rc.storage_type]['extension']}
      BANNER
      banner.each { |b| logger.info(b) } unless logger.nil?

      server = WEBrick::HTTPServer.new(:Port            => @sc.port.to_i,
                                       :StartThreads    => @sc.threads.to_i,
                                       :AcceptCallback  => localonly,
                                       :Logger          => logger)
      @rc.logger = logger
      Ruwiki::Servlet.config = @rc

      server.mount(@sc.mount, Ruwiki::Servlet)
      trap("INT") { server.shutdown; return }
      server.start
    end
  end
end
