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

module Ruwiki::Utils::Converter
  class << self
    TARGETS = %w(flatfiles yaml marshal)

      # Create the regular expressions that are used in Ruwiki 0.6.2
    OLD_HEADER_RE       = /^\s*([a-z]+)\s*:\s*(.*)$/
    OLD_HEADER_END_RE   = /^#EHDR$/
    DATA_HEADER_END_RE  = /\A#EHDR\z/
    NL_RE               = /\n/

    def with(obj)
      yield obj if block_given?
    end

      # Only allow this to be run once. Silently fail otherwise.
    def set_defaults
      return unless @options.nil?
      @options = OpenStruct.new

      with @options do |o|
        o.traverse_directories  = true
        o.backup_old_files      = true
        o.backup_extension      = "~"
        o.quiet                 = false
        o.verbose               = false
        o.extension             = 'ruwiki'
        o.target_format         = 'flatfiles'
      end
    end

    def message=(lang)
      if lang.kind_of?(Hash)
        @message = lang
      elsif "constant" == defined?(lang::Message)
        @message = lang::Message
      else
        raise ArgumentError
      end
    end
    def message(id)
      if @message[id].nil?
        []
      else
        @message[id]
      end
    end

    def display_options
    end

    def summary
    end

    def run(argv, input = $stdin, output = $stdout, error = $stderr)
      set_defaults

      @input  = input
      @output = output
      @error  = error

      language = 'en'
      find_lang = argv.grep(%r{^--lang})
      find_lang.each do |ee|
        if ee =~ %r{^--lang=}
          language = ee.sub(%r{^--lang=}, '')
        else
          language = argv[argv.index(ee).succ]
        end
      end

      require "ruwiki/lang/#{language.downcase}"
      self.message = Ruwiki::Lang.const_get(language.upcase)

      argv.options do |opts|
        opts.banner = message(:converter_usage) % File.basename($0)
        opts.separator ''
        opts.on('--format=FORMAT', *message(:converter_format_desc)) do |ff|
          @options.target_format = ff
        end
        opts.on('--[no-]backup', *message(:converter_backup_desc)) do |bb|
          @options.backup_old_files = bb
        end
        opts.on('--backup-extension=EXTENSION', *message(:converter_backupext_desc)) do |ee|
          if ee.nil? or ee.empty?
            @error << message(:converter_backupext_error) if ee.nil? or ee.empty?
            @error << "#{opts}\n"
            return 0
          end
          @options.backup_extension = ee
        end
        opts.on('--extension=EXTENSION', *message(:converter_extension_desc)) do |ee|
          if ee.nil? or ee.empty?
            @error << message(:converter_extension_error) if ee.nil? or ee.empty?
            @error << "#{opts}\n"
            return 0
          end
          @options.extension = ee
        end
        opts.on('--no-extension', *message(:converter_noextension_desc)) do
          @options.extension = nil
        end
        opts.on('--lang=LANG', *message(:converter_language_desc)) do |lang|
          self.message = Ruwiki::Lang.const_get(lang.upcase)
        end
        opts.on('--quiet', *message(:converter_quiet_desc)) do |qq|
          @options.quiet   = qq
          @options.verbose = (not qq)
        end
        opts.on('--verbose', *message(:converter_verbose_desc)) do |vv|
          @options.quiet   = (not vv)
          @options.verbose = vv
        end
        opts.separator ''
        opts.on_tail('--help', *message(:converter_help_desc)) do
          @error << "#{opts}\n"
          return 0
        end

        opts.parse!
      end

      if argv.empty?
        @error << message(:converter_num_arguments) << "\n#{argv.options}\n" unless @options.quiet
        return 127
      end

      display_options if @options.verbose

      @options.target_format.capitalize!
      @options.target_format_class = Ruwiki::Backend.const_get(@options.target_format)

      argv.each { |file| process_file(file) }

      summary if not @options.quiet
    end

      # Process a single file.
    def process_file(file)
      if @options.backup_old_files
        return if file =~ /#{@options.backup_extension}/
      end
      @out << "#{file}: " unless @options.quiet

      if File.directory?(file) and @options.traverse_directories
        @out << message(:converter_directory) << "\n" unless @options.quiet
        Dir.chdir(file) { Dir['*'].each { |entry| process_file(entry) } }
      else
        begin
          page, page_format = load_page(file)
          @out << message(:converter_converting_from) % [ page_format, @options.target_format ] if @options.verbose
          save_page(file, page)
          @out << message(:converter_done) << "\n" unless @options.quiet
        rescue PageLoadException
          @out << message(:converter_not_ruwiki) << "\n" unless @options.quiet
        rescue PageSaveException
          @out << message(:cannot_nosave_modified) << "\n" % [ file ] unless @options.quiet
        end
      end
    end

    def load_page(file)
      data = File.read(file)
      page_format = nil

      if data =~ OLD_HEADER_END_RE
        page_format = 'OldFlatfiles'

        page = Ruwiki::Page::NULL_PAGE.dup

        unless data.empty?
          rawbuf = data.split(NL_RE).map { |e| e.chomp }

          loop do
            if rawbuf[0] =~ OLD_HEADER_END_RE
              rawbuf.shift
              break
            end

            match = OLD_HEADER_RE.match(rawbuf[0])

            unless match.nil?
              case match.captures[0]
              when 'topic'
                page['properties']['topic'] = match.captures[1]
                page['properties']['title'] = match.captures[1]
              when 'version'
                page['properties']['version'] = match.captures[1].to_i
              else
                nil
              end
            end
            rawbuf.shift
          end

          page['page']['content'] = rawbuf.join("\n")

          with page['properties'] do |pp|
            pp['project']    = File.basename(File.dirname(File.expand_path(file)))
            pp['editable']   = true
            pp['indexable']  = true
            pp['entropy']    = 0.0
          end
        end
      end

        # Try Marshal
      if page_format.nil?
        begin
          page = ::Marshal.load(data)
          page_format = 'Marshal'
        rescue Exception
          nil
        end
      end

        # Try YAML
      if page_format.nil?
        begin
          page = YAML.load(data)
          page_format = 'YAML'
        rescue Exception
          nil
        end
      end

        # Try the Flatfiles format
      if page_format.nil?
        begin
          page = Ruwiki::Backend::Flatfiles.load(data)
          page_format = 'Flatfiles'
        rescue Exception =>e
          nil
        end
      end

      if page_format.nil? # Cannot detect page type.
        @error << %Q|Cannot detect the page format. |
        raise PageLoadException
      end
      [page, page_format]
    rescue PageLoadException
      raise
    rescue Exception
      @error << %Q|#{e.message}\n#{e.backtrace.join("\n")}\n| if @options.verbose
      raise PageLoadException
    end

    def save_page(file, page)
      if @options.backup_extension != '~'
        backup = "#{file}.#{@options.backup_extension}"
      else
        backup = "#{file}#{@options.backup_extension}"
      end

          # Always backup the file -- we are transactional.
      FileUtils.cp(file, backup)

      if @options.target_format == 'Marshal'
        method = :print
      else
        method = :puts
      end
      File.open(file, 'wb') { |f| f.__send__(method, @options.target_format_class.dump(page)) }
    rescue Exception => ee
      FileUtils.mv(backup, file) if File.exists?(backup)
      @error << %Q|#{ee.message}\n#{ee.backtrace.join("\n")}\n| if @options.verbose
      raise PageSaveException
    ensure
      # If we aren't *supposed* to back up the file, then get rid of the
      # backup.
      if File.exists?(backup) and (not @options.backup_old_files)
        FileUtils.rm(backup)
      end
    end

    class PageLoadException < RuntimeError; end
    class PageSaveException < RuntimeError; end
  end
end
