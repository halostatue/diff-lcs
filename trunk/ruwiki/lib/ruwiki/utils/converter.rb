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

    def display_options
    end

    def summary
    end

    def run(argv, input = $stdin, output = $stdout, error = $stderr)
      set_defaults

      @input  = input
      @output = output
      @error  = error

      argv.options do |opts|
        opts.banner = "Usage: converter [options] <directory>+"
        opts.separator ''
        opts.on('--format=FORMAT', 'Converts encountered files (regardless', 'of the current format), to the specified', 'format. Default is yaml. Allowed formats', 'are:     yaml marshal flatfiles') do |ff|
          @options.target_format = ff
        end
        opts.on('--[no-]backup', 'Create backups of upgraded files.', 'Default is --backup.') do |bb|
          @options.backup_old_files = bb
        end
        opts.on('--backup-extension=EXTENSION', 'Specify the backup extension. Default', 'is "~", which is appended to the data', 'filename.') do |ee|
          if ee.nil? or ee.empty?
            @error << "The backup extension must not be empty." if ee.nil? or ee.empty?
            @error << "#{opts}\n"
            return 0
          end
          @options.backup_extension = ee
        end
        opts.on('--extension=EXTENSION', 'Specifies the extension of Ruwiki data', 'files. The default is .ruwiki') do |ee|
          @options.extension = ee
        end
        opts.on('--no-extension', 'Indicates that the Ruwiki data files', 'have no extension.') do |nn|
          @options.extension = nil
        end
        opts.on('--quiet', 'Runs quietly. Default is to run with', 'normal messages.') do |qq|
          @options.quiet   = qq
          @options.verbose = (not qq)
        end
        opts.on('--verbose', 'Runs with full messages. Default is to', 'run with normal messages.') do |vv|
          @options.quiet   = (not vv)
          @options.verbose = vv
        end
        opts.separator ''
        opts.on_tail('--help', 'Shows this text.') do
          @error << "#{opts}\n"
          return 0
        end

        opts.parse!
      end

      if argv.empty?
        @error << "Error: not enough arguments.\n#{argv.options}\n" if not @options.quiet
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
        @out << "directory\n" unless @options.quiet
        Dir.chdir(file) { Dir['*'].each { |entry| process_file(entry) } }
      else
        begin
          page, page_format = load_page(file)
          @out << "converting from #{page_format} to #{@options.target_format} ... " if @options.verbose
          save_page(file, page)
          @out << "done.\n" unless @options.quiet
        rescue PageLoadException
          @out << "not a Ruwiki file; skipping.\n" unless @options.quiet
        rescue PageSaveException
          @out << "cannot save modified #{file}.\n" unless @options.quiet
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

          with page['properties'] do |p|
            p['project']    = File.basename(File.dirname(File.expand_path(file)))
            p['editable']   = true
            p['indexable']  = true
            p['entropy']    = 0.0
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
