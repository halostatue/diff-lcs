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

require 'optparse'
require 'ostruct'
require 'fileutils'
require 'stringio'
require 'zlib'
require 'ruwiki/exportable'
require 'ruwiki/utils/command'
require 'ruwiki/config'

begin
  require 'rubygems'
  require_gem 'archive-tar-minitar', '~> 0.5.1'
rescue LoadError
  require 'archive/tar/minitar'
end

module Ruwiki::Utils::Manager
  DEFAULT_PACKAGE_NAME  = 'ruwiki.pkg'

  EXECUTABLES = %w(ruwiki.cgi ruwiki_servlet ruwiki_servlet.bat \
                   ruwiki_servlet.cmd ruwiki_service.rb)

  class ManagerHelp < Ruwiki::Utils::CommandPattern
    def name
      "help"
    end

    def call(args, opts = {}, ioe = {})
      ioe = Ruwiki::Utils::CommandPattern.default_ioe(ioe)
      help_on = args.shift
      output  = ""

      if Ruwiki::Utils::CommandPattern.command?(help_on)
        ioe[:output] << Ruwiki::Utils::CommandPattern[help_on].help
      elsif help_on == "commands"
        ioe[:output] << <<-EOH
The commands known to ruwiki are:

    ruwiki install              Installs the default deployment package.
    ruwiki package              Packages a Ruwiki installation.
    ruwiki unpackage            Unpackages a Ruwiki installation.
    ruwiki service              Manages a Win32::Service for Ruwiki.

        EOH
      else
        ioe[:output] << "Unknown command: #{help_on}\n" unless help_on.nil? or help_on.empty?
        ioe[:output] << self.help
      end

      0
    end

    def help
      help = <<-EOH
This is a basic help message containing pointers to more information on how
to use this command-line tool. Try:

    ruwiki help commands        list all 'ruwiki' commands
    ruwiki help <COMMAND>       show help on <COMMAND>
                                  (e.g., 'ruwiki help install')
      EOH
    end
  end

  class ManagerInstall < Ruwiki::Utils::CommandPattern
    def name
      "install"
    end

    def call(args, opts = {}, ioe = {})
      argv    = []

      replace = false
      dest    = "."
      name    = nil

      while (arg = args.shift)
        case arg
        when '--to'
          dir = args.shift
          raise ArgumentError if dir.nil?
          if File.exist?(dir)
            if not File.directory?(dir)
              raise ArgumentError
            end
          else
            FileUtils.mkdir_p(dir)
          end
          dest = dir
        when /;/o
          argv.push(*(arg.split(/;/o)))
        when /,/o
          argv.push(*(arg.split(/,/o)))
        else
          argv << arg
        end
      end

      options = { 'data' => true }

      while (arg = argv.shift)
        case arg
        when /^(?:-|no)(.*$)/
          options.delete($1)
        else
          options[arg] = true
        end
      end

      Ruwiki::Utils::Manager.install(dest, options)

      0
    end

    def help
      help = <<-EOH
    ruwiki install [OPTIONS] [--to DEST]

Creates a new Ruwiki instance. By default this installs the data, templates,
and a default configuration file to the current directory. The destination
can be changed with the --to option, and what is installed can be specified
with the OPTIONS list. The OPTIONS list may be space, comma, or semi-colon
separated. Thus,

    ruwiki install data;servlet
    ruwiki install data,servlet
    ruwiki install data servlet

are all equivalent. The options may be specified in any case. The
installation OPTIONS are:

    servlet       # Installs the Ruwiki servlet stub
    service       # Installs the Ruwiki Win32::Service stub
    CGI           # Installs the Ruwiki CGI script
    data          # Installs the Ruwiki data, templates, and configuration

Options may be disabled with by prepending a dash or 'no':

    ruwiki install cgi -data
    ruwiki install cgi nodata

These will install the CGI script but not the data.
      EOH
    end
  end

  class ManagerPackage < Ruwiki::Utils::CommandPattern
    def name
      "package"
    end

    def call(args, opts = {}, ioe = {})
      ioe = Ruwiki::Utils::CommandPattern.default_ioe(ioe)
      argv    = []
      replace = false
      dest    = "."
      name    = nil

      while (arg = args.shift)
        case arg
        when '--replace'
          replace = true
        when '-o', '--output'
          name  = args.shift
          raise ArgumentError if name.nil?
          dest  = File.dirname(name)
          name  = File.basename(name)
        else
          argv << arg
        end
      end

      raise ArgumentError if argv.size > 1
      source = argv.shift || "."
    
      Ruwiki::Utils::Manager.package(source, dest, name, replace)
      0
    end

    def help
      help = <<-EOH
    ruwiki package [SOURCE] [--output PACKAGE] [--replace]
    ruwiki package [SOURCE] [-o PACKAGE] [--replace]

Packages the Ruwiki files (data, templates, and executables) from the
specified SOURCE or the current directory into the specified output package
(or "./#{Ruwiki::Utils::Manager::DEFAULT_PACKAGE_NAME}"). If the SOURCE is a ruwiki configuration file (e.g.,
"#{Ruwiki::Config::CONFIG_NAME}"), then that will be used to determine the location and name of
the data and template directories.

    NOTE: The packaging process will normalize the data and templates
          directory names to be relative to the unpacking directory. They
          will NEVER be absolute paths.
      EOH
    end
  end

  class ManagerUnpackage < Ruwiki::Utils::CommandPattern
    def name
      "unpackage"
    end

    def call(args, opts = {}, ioe = {})
      ioe = Ruwiki::Utils::CommandPattern.default_ioe(ioe)
      argv    = []
      dir     = "."

      while (arg = args.shift)
        case arg
        when '-o', '--output'
          dir = args.shift
          raise ArgumentError if dir.nil? or not File.directory?(dir)
        else
          argv << arg
        end
      end

      raise ArgumentError if argv.size > 1
      source = argv.shift || Ruwiki::Utils::Manager::DEFAULT_PACKAGE_NAME

      Ruwiki::Utils::Manager.unpackage(source, dir)

      0
    end

    def help
      help = <<-EOH
    ruwiki unpackage [SOURCE] [--output DIRECTORY]
    ruwiki unpackage [SOURCE] [-o DIRECTORY]

Unpackages the provided Ruwiki package (default "./#{Ruwiki::Utils::Manager::DEFAULT_PACKAGE_NAME}") into the
specified directory (default ".").
      EOH
    end
  end

  if RUBY_PLATFORM =~ /win32/
    class ManagerService < Ruwiki::Utils::CommandPattern
      def name
        "service"
      end

      def call(args, opts = {}, ioe = {})
        ioe = Ruwiki::Utils::CommandPattern.default_ioe(ioe)

        if args.size < 2
          ioe[:output] << %<Insufficient arguments: #{args.join(" ")}\n>
          ioe[:output] << self.help
          return 0
        end

        command = args.shift
        service = args.shift

        options ||= {}
        options[:service_name] = service
        options[:service_home] = File.expand_path(".")

        argv  = []
        while (arg = args.shift)
          case arg
          when "--rubybin"
            options[:ruby_bin] = args.shift
            raise ARgumentError if options[:ruby_bin].nil?
          when "--exec"
            options[:service_bin] = args.shift
            raise ArgumentError if options[:service_bin].nil?
          when "--home"
            options[:service_home] = args.shift
            raise ArgumentError if options[:service_home].nil?
          else
            argv << arg
          end
        end

        options[:service_desc] = args.join(" ") if args.size > 0

        case command
        when "install"
          options[:service_install] = true
        when "start"
          options[:service_start] = true
        when "stop"
          options[:service_stop] = true
        when "delete"
          options[:service_delete] = true
        else
          raise ArgumentError, "Unknown command #{command}."
        end

        Ruwiki::Utils::Manager.manage_windows_service(options, ioe)

        0
      end

      def help
      help = <<-EOH
    ruwiki service install NAME [DESCRIPTION] [options]
    ruwiki service start   NAME
    ruwiki service stop    NAME
    ruwiki service delete  NAME

Manages the Ruwiki WEBrick servlet as a Windows service. The service must be
NAMEd. install supports the following additional options:

  --rubybin RUBYPATH      The path to the Ruby binary.
  --exec    SERVICEPATH   The path to the service executable.
  --home    PATHTOHOME    The path to the home directory.
      EOH
      end
    end
    Ruwiki::Utils::CommandPattern << ManagerService
  end

  Ruwiki::Utils::CommandPattern << ManagerHelp
  Ruwiki::Utils::CommandPattern << ManagerInstall
  Ruwiki::Utils::CommandPattern << ManagerPackage
  Ruwiki::Utils::CommandPattern << ManagerUnpackage
  Ruwiki::Utils::CommandPattern.default = Ruwiki::Utils::CommandPattern["help"]

  class << self
    attr_accessor :shared
    attr_reader   :ruwiki_servlet
    attr_reader   :ruwiki_servlet_bat
    attr_reader   :ruwiki_servlet_cmd
    attr_reader   :ruwiki_service
    attr_reader   :ruwiki_cgi
    attr_reader   :ruwiki_pkg
    def shared=(shared)
      @shared             = shared
      @ruwiki_servlet     = File.join(@shared, "bin", "ruwiki_servlet")
      @ruwiki_servlet_bat = File.join(@shared, "bin", "ruwiki_servlet.bat")
      @ruwiki_servlet_cmd = File.join(@shared, "bin", "ruwiki_servlet.cmd")
      @ruwiki_service     = File.join(@shared, "bin", "ruwiki_service.rb")
      @ruwiki_cgi         = File.join(@shared, "bin", "ruwiki.cgi")
      @ruwiki_pkg         = File.join(@shared, Ruwiki::Utils::Manager::DEFAULT_PACKAGE_NAME)
    end

    def with(obj)
      yield obj if block_given?
    end

    def tar_files(list, name)
      ff = StringIO.new
      gz = Zlib::GzipWriter.new(ff)
      to = Archive::Tar::Minitar::Output.new(gz)
      list.each { |item| Archive::Tar::Minitar.pack_file(item, to) }
      data = ff.string
      group = {
        :name   => name,
        :data   => data,
        :mode   => 0644,
      }
      return group
    rescue Exception => e
      puts e.message, e.backtrace.join("\n")
    ensure
      to.close
      group[:size] = group[:data].size
    end

    def package(source, dest, name = nil, replace = false)
      # If the package name is nil, use the default name. If replace is
      # false, then append a number on the end if the file already exists.
      # Increment the number until we have a unique filename.
      if name.nil?
        pkg = File.join(dest, DEFAULT_PACKAGE_NAME)
        if File.exists?(pkg) and (not replace)
          pbn = "#{File.basename(DEFAULT_PACKAGE_NAME, '.pkg')}-%02d.pkg"
          ii  = 1
          while File.exists?(pkg)
            pkg = File.join(dest, pbn % ii)
            ii += 1
          end
        end
      else
        pkg = File.join(dest, name)
        if File.exists?(pkg) and (not replace)
          raise "Package #{pkg} already exists."
        end
      end

      files = []

      if File.directory?(source)
        Dir.chdir(source) do
          if File.exists?(Ruwiki::Config::CONFIG_NAME)
            cs = File.stat(Ruwiki::Config::CONFIG_NAME)
            files << {
              :name   => Ruwiki::Config::CONFIG_NAME,
              :data   => File.read(Ruwiki::Config::CONFIG_NAME),
              :mtime  => cs.mtime,
              :mode   => 0644,
              :size   => cs.size
            }
          end

          EXECUTABLES.each do |ff|
            if File.exists?(ff)
              cs = File.stat(ff)
              files << {
                :name   => ff,
                :data   => File.read(ff),
                :mtime  => cs.mtime,
                :mode   => 0755,
                :size   => cs.size
              }
            end
          end

          f_data  = Dir["data/**/**"].select { |dd| dd !~ /CVS\// }
          f_data.map! { |dd| { :name => dd, :mode => 0644 } }
          f_tmpl  = Dir["templates/**/**"].select { |tt| tt !~ /CVS\// }
          f_tmpl.map! { |tt| { :name => tt, :mode => 0644 } }

          files << tar_files(f_data, "data.pkg")
          files << tar_files(f_tmpl, "tmpl.pkg")
        end
      else
        stat = File.stat(source)
        files << {
          :name   => File.basename(source),
          :data   => File.read(source),
          :mtime  => stat.mtime,
          :mode   => 0644,
          :size   => stat.size
        }

        EXECUTABLES.each do |ff|
          ff = File.join(File.dirname(source), ff)
          if File.exists?(ff)
            cs = File.stat(ff)
            files << {
              :name   => ff,
              :data   => File.read(ff),
              :mtime  => cs.mtime,
              :mode   => 0755,
              :size   => cs.size
            }
          end
        end

        cc = Ruwiki::Exportable.load(files[0][:data])
        tp = cc['ruwiki-config']['template-path']
        tp = "./templates" if tp.nil? or tp.empty?
        so = cc['ruwiki-config']['storage-options']

        if so.nil? or so.empty?
          dp = "./data"
        else
          so = Ruwiki::Exportable.load(so)
          if so['flatfiles']
            key = 'flatfiles'
          elsif so['yaml']
            key = 'yaml'
          elsif so['marshal']
            key = 'marshal'
          end
        end

        dp = so[key]['data-path']
        dp = "./data" if dp.nil? or dp.empty?
        bndp = File.basename(dp)
        bntp = File.basename(tp)

        so[key]['data-path'] = bndp
        cc['ruwiki-config']['storage-options'] = Ruwiki::Exportable.dump(so)
        cc['ruwiki-config']['template-path'] = bntp
        files[0][:data] = Ruwiki::Exportable.dump(cc)
        files[0][:size] = files[0][:data].size

        Dir.chdir(File.dirname(dp)) do
          f_data = Dir["#{bndp}/**/**"].select { |dd| dd !~ /CVS\// }
          f_data.map! { |dd| { :name => dd, :mode => 0644 } }
          files << tar_files(f_data, "data.pkg")
        end

        Dir.chdir(File.dirname(tp)) do
          f_tmpl = Dir["#{bntp}/**/**"].select { |tt| tt !~ /CVS\// }
          f_tmpl.map! { |tt| { :name => tt, :mode => 0644 } }
          files << tar_files(f_tmpl, "tmpl.pkg")
        end
      end

      ff = File.open(pkg, "wb")
      gz = Zlib::GzipWriter.new(ff)
      tw = Archive::Tar::Minitar::Writer.new(gz)

      files.each do |entry|
        tw.add_file_simple(entry[:name], entry) { |os| os.write(entry[:data]) }
      end

      nil
    rescue Exception => e
      puts e
      puts e.backtrace.join("\n")
    ensure
      tw.close if tw
      gz.close if gz
    end

    def unpackage(source, dest)
      ff = File.open(source, "rb")
      gz = Zlib::GzipReader.new(ff)
      Archive::Tar::Minitar::Input.open(gz) do |it|
        it.each do |entry|
          case entry.full_name
          when "data.pkg", "tmpl.pkg"
            pkg   = StringIO.new(entry.read)
            pkgz  = Zlib::GzipReader.new(pkg)
            Archive::Tar::Minitar::Input.open(pkgz) do |inner|
              inner.each { |item| inner.extract_entry(dest, item) }
            end
          else
            it.extract_entry(dest, entry)
          end
        end
      end

      nil
    end

    def install(dest, options = {})
      if options['servlet']
        FileUtils.install(Ruwiki::Utils::Manager.ruwiki_servlet, dest, :mode => 0755)
        if RUBY_PLATFORM =~ /win32/
          if File.exists?(Ruwiki::Utils::Manager.ruwiki_servlet_bat)
            FileUtils.install(Ruwiki::Utils::Manager.ruwiki_servlet_bat, dest)
          end
          if File.exists?(Ruwiki::Utils::Manager.ruwiki_servlet_cmd)
            FileUtils.install(Ruwiki::Utils::Manager.ruwiki_servlet_cmd, dest)
          end
        end
      end

      if RUBY_PLATFORM =~ /win32/ and options['service']
        FileUtils.install(Ruwiki::Utils::Manager.ruwiki_service, dest)
      end

      if options['cgi']
        FileUtils.install(Ruwiki::Utils::Manager.ruwiki_cgi, dest, :mode => 755)
      end

      if options['data']
        unpackage(Ruwiki::Utils::Manager.ruwiki_pkg, dest)
      end
    end

    if RUBY_PLATFORM =~ /win32/
      begin
        require 'win32/service'
        require 'rbconfig'
        HasWin32Service = true
      rescue LoadError
        HasWin32Service = false
      end

      # The work here is based on Daniel Berger's Instiki Service Tutorial.
      # http://rubyforge.org/docman/view.php/85/107/instiki_service_tutorial.txt
      def manage_windows_service(options, ioe)
        raise unless HasWin32Service

        service_name  = options[:service_name] || 'RuwikiSvc'

        if options[:service_install]
          service_home  = options[:service_home]

          program       = options[:service_bin]
          if program.nil? or program.empty?
            program     = File.join(service_home, "ruwiki_service.rb")
          elsif program !~ %r{[/\\]}
            program     = File.join(service_home, program)
          end
          program       = %<"#{program}">

          ruby          = options[:ruby_bin] || %<"#{File.join(Config::CONFIG['bindir'], 'ruby.exe')}">

          service_desc  = options[:service_desc] || 'Ruwiki'

          binpath       = "#{ruby} #{program}".tr('/', '\\')

          service = Win32::Service.new
          service.create_service do |s|
            s.service_name      = service_name
            s.display_name      = service_desc
            s.binary_path_name  = binpath
            s.dependencies      = [] # Required because of a bug in Win32::Service
          end
          service.close
          ioe[:output] << "#{service_name} service installed.\n"
        end

        if options[:service_start]
          Win32::Service.start(service_name)
          started = false
          while (not started)
            status  = Win32::Service.status(service_name)
            started = (status.current_state == "running")
            break if started
            ioe[:output] << "One moment, #{status.current_state}\n"
            sleep 1
          end
          ioe[:output] << "#{service_name} service started.\n"
        end

        if options[:service_stop]
          Win32::Service.stop(service_name)
          stopped = false
          while (not stopped)
            status  = Win32::Service.status(service_name)
            stopped = (status.current_state == "stopped")
            break if stopped
            ioe[:output] << "One moment, #{status.current_state}\n"
            sleep 1
          end
          ioe[:output] << "#{service_name} service stopped.\n"
        end

        if options[:service_delete]
          Win32::Service.stop(service_name) rescue nil
          Win32::Service.delete(service_name)
          ioe[:output] << "#{service_name} service deleted.\n"
        end
      end
    end

    def run(argv, input = $stdin, output = $stdout, error = $stderr)
      ioe = {
        :input  => input,
        :output => output,
        :error  => error
      }

      command = Ruwiki::Utils::CommandPattern[(argv.shift or "").downcase]
      return command[argv, {}, ioe]
    end
  end
end
