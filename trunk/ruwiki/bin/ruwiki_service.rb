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

  # 1) Try to load Ruwiki from the gem.
  # 2) Try to load Ruwiki from $LOAD_PATH.
  # 3) Modify $LOAD_PATH and try to load it from the modified $LOAD_PATH.
  # 4) Fail hard.
load_state = 1
begin
  if 1 == load_state
    require 'rubygems'
    require_gem 'ruwiki', '= 0.9.0'
  else
    require 'ruwiki'
  end
rescue LoadError
  load_state += 1

  case load_state
  when 3
    $LOAD_PATH.unshift "#{File.dirname($0)}/../lib"
  when 4
    $LOAD_PATH.shift
    $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
  when 5
    raise
  end
  retry
end

require 'win32/service'
require 'ruwiki/utils/servletrunner'

class Ruwiki::Utils::Daemon < Win32::Daemon
  LOCATION = File.dirname(File.expand_path(__FILE__))

  def initialize
    @logfile = File.open(File.join(LOCATION, "ruwiki_service.log"), "ab+")
  rescue Exception => e
    File.open(File.join(LOCATION, "temp.log"), "a+") do |f|
      f.puts "Logfile error: #{e}"
      f.puts "Backtrace:\n#{e.backtrace.join(', ')}"
    end
    exit
  end

  def service_main
    ARGV.replace(["--config", File.join(LOCATION, Ruwiki::Config::CONFIG_NAME),
                  "--logfile", File.join(LOCATION, "ruwiki_servlet.log")])
    Ruwiki::Utils::ServletRunner.run(ARGV, @logfile, @logfile, @logfile)
  rescue Exception => e
    file = LOCATION + '/temp.log'
    File.open(file, "a+") do |f|
      f.puts "Error: #{e}"
      f.puts "Backtrace: #{e.backtrace.join(', ')}"
    end
    exit
  end
end

daemon = Ruwiki::Utils::Daemon.new
daemon.mainloop
