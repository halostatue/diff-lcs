#!/usr/bin/env ruby
#--
# Ruwiki version 0.8.0
#   Copyright © 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# This file is based on and incorporating parts of RPA::Package (rpa-base's
# lib/rpa/package.rb and lib/rpa/util.rb) by Marucio Julio Fernández Pradier,
# copyright © 2004.
#
# This file is licensed under the following conditions [NOTE: this file does
# not fall under condition 4; there is no LEGAL file to be concerned about]:
#
# You can redistribute it and/or modify it under either the terms of the GNU
# General Public License, or:
#
# 1. You may make and give away verbatim copies of the source form of the
#    software without restriction, provided that you duplicate all of the
#    original copyright notices and associated disclaimers.
#
# 2. You may modify your copy of the software in any way, provided that you do
#    at least ONE of the following:
#
#    a) place your modifications in the Public Domain or otherwise make them
#       Freely Available, such as by posting said modifications to Usenet or an
#       equivalent medium, or by allowing the author to include your
#       modifications in the software.
#    b) use the modified software only within your corporation or organization.
#    c) give non-standard binaries non-standard names, with instructions on
#       where to get the original software distribution.
#    d) make other distribution arrangements with the author.
# 3. You may distribute the software in object code or binary form, provided
#    that you do at least ONE of the following:
#    a) distribute the binaries and library files of the software, together
#       with instructions (in the manual page or equivalent) on where to get
#       the original distribution.
#    b) accompany the distribution with the machine-readable source of the
#       software.
#    c) give non-standard binaries non-standard names, with instructions on
#       where to get the original software distribution.
#    d) make other distribution arrangements with the author.
# 4. You may modify and include the part of the software into any other
#    software (possibly commercial).  But some files in the distribution are
#    not written by the author, so that they are not under these terms.
#
#    For the list of those files and their copying conditions, see the file
#    LEGAL.
# 5. The scripts and library files supplied as input to or produced as output
#    from the software do not automatically fall under the copyright of the
#    software, but belong to whomever generated them, and may be sold
#    commercially, and may be aggregated with this software.
# 6. THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
#    WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
#    MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# $Id$
#++

require 'fileutils'
require 'find'

module Tar
  class NonSeekableIO < StandardError; end
  class ArgumentError < ::ArgumentError; end
  class ClosedIO < StandardError; end
  class BadCheckSum < StandardError; end
  class TooLongFileName < StandardError; end
  class InvalidMode < ::ArgumentError; end
  class BlockNeeded < StandardError; end

  module FSyncDir
  private
    def fsync_dir(dirname)
        # make sure this hits the disc
      begin
        dir = open(dirname, "r")
        dir.fsync
      rescue # ignore IOError if it's an unpatched (old) Ruby
      ensure
        dir.close if dir rescue nil
      end
    end

    def dir?(path)
      # Apparently fixes a corrupted stat() on Windows:
      File.directory?((path[-1] == ?/) ? path : "#{path}/")
    end
  end

  class Header
    FIELDS = [:name, :mode, :uid, :gid, :size, :mtime, :checksum, :typeflag,
              :linkname, :magic, :version, :uname, :gname, :devmajor,
              :devminor, :prefix]
    FIELDS.each { |x| attr_reader x }

      # The tarfile header:
      #
      # struct tarfile_entry_posix
      # {
      #    char name[100];     // ASCII (+ Z unless filled)     A100
      #    char mode[8];       // 0 padded, octal, null         A8
      #    char uid[8];        // ditto                         A8
      #    char gid[8];        // ditto                         A8
      #    char size[12];      // 0 padded, octal, null         A12
      #    char mtime[12];     // 0 padded, octal, null         A12
      #    char checksum[8];   // 0 padded, octal, null, space  A8
      #    char typeflag[1];   // file: "0"  dir: "5"           A
      #    char linkname[100]; // ASCII + (Z unless filled)     A100
      #    char magic[6];      // "ustar\0"                     A6
      #    char version[2];    // "00"                          A2
      #    char uname[32];     // ASCIIZ                        A32
      #    char gname[32];     // ASCIIZ                        A32
      #    char devmajor[8];   // 0 padded, octal, null         A8
      #    char devminor[8];   // o padded, octal, null         A8
      #    char prefix[155];   // ASCII (+ Z unless filled)     A155
      # };
    HEADER_PACK_FORMAT = "A100A8A8A8A12A12A8AA100A6A2A32A32A8A8A155"

    def self.new_from_stream(stream)
      data = stream.read(512)
      fields    = data.unpack(HEADER_PACK_FORMAT)
      name      = fields.shift
      mode      = fields.shift.oct
      uid       = fields.shift.oct
      gid       = fields.shift.oct
      size      = fields.shift.oct
      mtime     = fields.shift.oct
      checksum  = fields.shift.oct
      typeflag  = fields.shift
      linkname  = fields.shift
      magic     = fields.shift
      version   = fields.shift.oct
      uname     = fields.shift
      gname     = fields.shift
      devmajor  = fields.shift.oct
      devminor  = fields.shift.oct
      prefix    = fields.shift

      empty = (data == "\0" * 512)

      new(:name => name, :mode => mode, :uid => uid, :gid => gid,
          :size => size, :mtime => mtime, :checksum => checksum,
          :typeflag => typeflag, :magic => magic, :version => version,
          :uname => uname, :gname => gname, :devmajor => devmajor,
          :devminor => devminor, :prefix => prefix, :empty => empty)
    end

    def initialize(vals)
      unless vals[:name] && vals[:size] && vals[:prefix] && vals[:mode]
        raise Tar::ArgumentError
      end

      vals[:mtime]    ||= 0
      vals[:checksum] ||= ""
      vals[:typeflag] ||= "0"
      vals[:magic]    ||= "ustar  "
      vals[:version]  ||= "\0\0"
      vals[:devmajor]
      vals[:devminor]

      FIELDS.each { |x| instance_variable_set "@#{x.to_s}", vals[x] }

      @empty = vals[:empty]
    end

    def empty?
      @empty
    end

    def to_s
      update_checksum
      header(@checksum)
    end

    def update_checksum
      h = header(" " * 8)
      @checksum = oct(calculate_checksum(h), 6)
    end

  private
    def null_pad(val, len)
      if val.nil?
        "\0" * len
      else
        %Q|#{val}#{"\0" * (len - val.size + 1)}|
      end
    end

    def oct(num, len)
      if num.nil?
        "\0" * (len + 1)
      else
        "%0#{len}o" % num
      end
    end

    def calculate_checksum(hdr)
      hdr.unpack("C*").inject { |a, b| a + b }
    end

    def header(chksum)
      arr = [null_pad(name, 100), oct(mode, 7), oct(uid, 7), oct(gid, 7),
             oct(size, 11), oct(mtime, 11), chksum, typeflag,
             null_pad(linkname, 100), null_pad(magic, 8), version,
             null_pad(uname, 32), null_pad(gname, 32), oct(devmajor, 7),
             oct(devminor, 7), null_pad(prefix, 155)]
      str = arr.pack(HEADER_PACK_FORMAT)
      str + "\0" * ((512 - str.size) % 512)
    end
  end

  class Writer
    class FileOverflow < StandardError; end

    class BoundedStream
      attr_reader :limit, :written

      def initialize(io, limit)
        @io = io
        @limit = limit
        @written = 0
      end

      def write(data)
        if data.size + @written > @limit
          raise FileOverflow,
            "You tried to feed more data than fits in the file."
        end
        @io.write data
        @written += data.size
        data.size
      end
    end

    class RestrictedStream
      def initialize(anIO)
        @io = anIO
      end

      def write(data)
        @io.write data
      end
    end

    def self.new(anIO)
      writer = super(anIO)

      return writer unless block_given?

      begin
        yield writer
      ensure
        writer.close
      end

      nil
    end

    def initialize(anIO)
      @io     = anIO
      @closed = false
    end

    def add_file_simple(name, mode, size)
      raise BlockNeeded unless block_given?
      raise ClosedIO if @closed

      name, prefix = split_name(name)

      header = Header.new(:name => name, :mode => mode, :size => size,
                          :prefix => prefix).to_s

      @io.write header

      os = BoundedStream.new(@io, size)
      yield os
        #FIXME: what if an exception is raised in the block?

      min_padding = size - os.written
      @io.write("\0" * min_padding)
      remainder = (512 - (size % 512)) % 512
      @io.write("\0" * remainder)
    end

    def add_file(name, mode)
      raise BlockNeeded unless block_given?
      raise ClosedIO if @closed
      raise NonSeekableIO unless @io.respond_to?(:pos=)

      name, prefix = split_name(name)
      init_pos = @io.pos
      @io.write "\0" * 512 # placeholder for the header

      yield RestrictedStream.new(@io)
        #FIXME: what if an exception is raised in the block?

      size = @io.pos - init_pos - 512
      remainder = (512 - (size % 512)) % 512
      @io.write("\0" * remainder)
      final_pos = @io.pos
      @io.pos = init_pos

      header = Header.new(:name => name, :mode => mode, :size => size,
                          :prefix => prefix).to_s

      @io.write header
      @io.pos = final_pos
    end

    def mkdir(name, mode)
      raise ClosedIO if @closed
      name = "#{name}/" if name[-1] != ?/
      name, prefix = split_name(name)
      header = Header.new(:name => name, :mode => mode, :typeflag => "5",
                          :size => 0, :prefix => prefix).to_s
      @io.write header
      nil
    end

    def flush
      raise ClosedIO if @closed
      @io.flush if @io.respond_to?(:flush)
    end

    def close
      return if @closed
      @io.write "\0" * 1024
      @closed = true
    end

  private
    def split_name name
      raise TooLongFileName if name.size > 256
      if name.size <= 100
        prefix = ""
      else
      parts = name.split(/\//)
      newname = parts.pop

      nxt = ""

      loop do
        nxt = parts.pop
        break if newname.size + 1 + nxt.size > 100
        newname = "#{nxt}/#{newname}"
      end

      prefix = (parts + [nxt]).join("/")

      name = newname

      raise TooLongFileName if name.size > 100 || prefix.size > 155
      end
      return name, prefix
    end
  end

  class Reader
    class UnexpectedEOF < StandardError; end

    module InvalidEntry
      def read(len = nil); raise ClosedIO; end
      def getc; raise ClosedIO;  end
      def rewind; raise ClosedIO;  end
    end

    class Entry
      Header::FIELDS.each { |x| attr_reader x }

      def initialize(header, anIO)
        @io = anIO
        @name = header.name
        @mode = header.mode
        @uid = header.uid
        @gid = header.gid
        @size = header.size
        @mtime = header.mtime
        @checksum = header.checksum
        @typeflag = header.typeflag
        @linkname = header.linkname
        @magic = header.magic
        @version = header.version
        @uname = header.uname
        @gname = header.gname
        @devmajor = header.devmajor
        @devminor = header.devminor
        @prefix = header.prefix
        @read = 0
        @orig_pos = @io.pos
      end

      def read(len = nil)
        return nil if @read >= @size
        len ||= @size - @read
        max_read = [len, @size - @read].min
        ret = @io.read(max_read)
        @read += ret.size
        ret
      end

      def getc
        return nil if @read >= @size
        ret = @io.getc
        @read += 1 if ret
        ret
      end

      def is_directory?
        @typeflag == "5"
      end

      def is_file?
        @typeflag == "0"
      end

      def eof?
        @read >= @size
      end

      def pos
        @read
      end

      def rewind
        raise NonSeekableIO unless @io.respond_to?(:pos=)
          @io.pos = @orig_pos
        @read = 0
      end

      alias_method :is_directory, :is_directory?
      alias_method :is_file, :is_file

      def bytes_read
        @read
      end

      def full_name
        if @prefix != ""
          File.join(@prefix, @name)
        else
          @name
        end
      end

      def close
        invalidate
      end

      private
      def invalidate
        extend InvalidEntry
      end
    end

    def self.new(anIO)
      reader = super(anIO)
      return reader unless block_given?
      begin
        yield reader
      ensure
        reader.close
      end
      nil
    end

    def initialize(anIO)
      @io = anIO
      @init_pos = anIO.pos
    end

    def each(&block)
      each_entry(&block)
    end

      # do not call this during a #each or #each_entry iteration
    def rewind
      if @init_pos == 0
        raise NonSeekableIO unless @io.respond_to?(:rewind)
        @io.rewind
      else
        raise NonSeekableIO unless @io.respond_to?(:pos=)
          @io.pos = @init_pos
      end
    end

    def each_entry
      loop do
        return if @io.eof?
        header = Header.new_from_stream(@io)
        return if header.empty?
        entry = Entry.new header, @io
        size = entry.size
        yield entry
        skip = (512 - (size % 512)) % 512
        if @io.respond_to?(:seek)
            # avoid reading...
          @io.seek(size - entry.bytes_read, IO::SEEK_CUR)
        else
          pending = size - entry.bytes_read
          while pending > 0
            bread = @io.read([pending, 4096].min).size
            raise UnexpectedEOF if @io.eof?
            pending -= bread
          end
        end
        @io.read(skip) # discard trailing zeros
          # make sure nobody can use #read, #getc or #rewind anymore
        entry.close
      end
    end

    def close
    end
  end

  class Input
    include FSyncDir
    include Enumerable

    class << self
      private :new

      def open(input)
        raise BlockRequired unless block_given?

        is = new(input)
        yield is
        return nil
      ensure
        is.close if is
      end
    end

    def initialize(input)
      if input.respond_to?(:read)
        @io = input
      else
        @io = open(filename, "rb")
      end
      @tarreader = Tar::Reader.new(@io)
    end

    def each(&block)
      @tarreader.each { |entry| yield entry }
    ensure
      @tarreader.rewind
    end

    def extract_entry(destdir, entry, expected_md5sum = nil)
      if entry.is_directory?
        dest = File.join(destdir, entry.full_name)
        if dir?(dest)
          begin
            FileUtils.chmod(entry.mode, dest)
          rescue Exception
            nil
          end
        else
          FileUtils.mkdir_p(dest, :mode => entry.mode)
        end
        fsync_dir(dest)
        fsync_dir(File.join(dest, ".."))
        return
      else # it's a file
        md5 = Digest::MD5.new if expected_md5sum
        destdir = File.join(destdir, File.dirname(entry.full_name))
        FileUtils.mkdir_p(destdir, :mode => 0755)
        destfile = File.join(destdir, File.basename(entry.full_name))
        FileUtils.chmod(0600, destfile) rescue nil  # Errno::ENOENT
        File.open(destfile, "wb", entry.mode) do |os|
          loop do
            data = entry.read(4096)
            break unless data
            md5 << data if expected_md5sum
            os.write(data)
          end
          os.fsync
        end
        FileUtils.chmod(entry.mode, destfile)
        fsync_dir(File.dirname(destfile))
        fsync_dir(File.join(File.dirname(destfile), ".."))
        if expected_md5sum && expected_md5sum != md5.hexdigest
          raise BadCheckSum
        end
      end
    end

    def close
      @io.close
      @tarreader.close
    end
  end

  class Output
    class << self
      private :new

      def open(output, &block)
        raise BlockNeeded unless block
        outputter = new(output)

        yield outputter.external_handle
        return nil
      ensure
        outputter.close if outputter
      end
    end

    def initialize(output)
      if output.respond_to?(:write)
        @io = output
      else
        @io = ::File.open(output, "wb")
      end
      @external = Tar::Writer.new(@io)
    end

    def external_handle
      @external
    end

    def close
      @external.close
      @io.close
    end
  end

  class << self
    include FSyncDir

    def open(dest, mode = "r", &block)
      raise BlockNeeded unless block

      case mode
      when "r"
        Input.open(dest, &block)
      when "w"
        Output.open(dest, &block)
      else
        raise "Unknown TarFile open mode"
      end
    end

    def pack_entry(entry, outputter)
      entry = entry.sub(%r{\./}, '')
      stat = File.stat(entry)
      case
      when File.file?(entry)
        outputter.add_file_simple(entry, stat.mode, stat.size) do |os|
          File.open(entry, "rb") { |f| os.write(f.read(4096)) until f.eof? }
        end
      when dir?(entry)
        outputter.mkdir(entry, stat.mode)
      else
        raise "Don't yet know how to pack this type of file."
      end
    end

    def pack(src, dest)
      Output.open(dest) do |outp|
        if src.kind_of?(String)
          Find.find(src) { |entry| pack_entry(entry, outp) }
        else
          src.each do |ee|
            Find.find(ee) { |entry| pack_entry(entry, outp) }
          end
        end
      end
    end

    def unpack(src, dest, files = [])
      Input.open(src) do |inp|
        if File.exist?(dest) and (not dir?(dest))
          raise "Can't unpack to a non-directory."
        elsif not File.exist?(dest)
          FileUtils.mkdir_p(dest)
        end

        inp.each { |entry| inp.extract_entry(dest, entry) }
      end
    end
  end
end
