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

class Ruwiki::Utils::CommandPattern
  class AbstractCommandError < Exception; end
  class UnknownCommandError < RuntimeError; end
  class CommandAlreadyExists < RuntimeError; end

  class << self
    def add(command)
      command = command.new if command.kind_of?(Class)

      @commands ||= {}
      if @commands.has_key?(command.name)
        raise CommandAlreadyExists
      else
        @commands[command.name] = command
      end

      if command.respond_to?(:altname)
        unless @commands.has_key?(command.altname)
          @commands[command.altname] = command
        end
      end
    end

    def <<(command)
      add(command)
    end

    attr_accessor :default
    def default=(command) #:nodoc:
      if command.kind_of?(Ruwiki::Utils::CommandPattern)
      @default = command
      elsif command.kind_of?(Class)
        @default = command.new
      elsif @commands.has_key?(command)
        @default = @commands[command]
      else
        raise UnknownCommandError
      end
    end

    def command?(command)
      @commands.has_key?(command)
    end

    def command(command)
      if command?(command)
        @commands[command]
      else
        @default
      end
    end

    def [](cmd)
      self.command(cmd)
    end

    def default_ioe(ioe = {})
      ioe[:input]   ||= $stdin
      ioe[:output]  ||= $stdout
      ioe[:error]   ||= $stderr
      ioe
    end
  end

  def [](args, opts = {}, ioe = {})
    call(args, opts, ioe)
  end

  def name
    raise AbstractCommandError
  end

  def call(args, opts = {}, ioe = {})
    raise AbstractCommandError
  end

  def help
    raise AbstractCommandError
  end
end
