#!/usr/bin/env ruby
#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

  # 1) Try to load Ruwiki from the local directory structure (e.g., ./lib/
  #    and ../lib/).
  # 2) Try to load Ruwiki from the directory structure of the running script
  #    (e.g., File.dirname($0)/lib and File.dirname($0)/../lib).
  # 3) Try to load Ruwiki from the directory structure of the current file
  #    (e.g., File.dirname(__FILE__)/lib and File.dirname(__FILE__)/../lib).
  # 4) Try to load Ruwiki from an unmodified $LOAD_PATH, e.g., site_ruby.
  # 5) Try to load Ruwiki from Rubygems.
  # 6) Fail hard.
load_state = 1

$LOAD_PATH.unshift "#{Dir.pwd}/lib", "#{Dir.pwd}/../lib"

begin
  require 'ruwiki'
rescue LoadError
  if (1..3).include?(load_state)
    $LOAD_PATH.shift # Oh, what I'd give for $LOAD_PATH.shift(2)
    $LOAD_PATH.shift
  end

  load_state += 1

  case load_state
  when 2
    $LOAD_PATH.unshift "#{File.dirname($0)}/lib", "#{File.dirname($0)}/../lib"
  when 3
    $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib", "#{File.dirname(__FILE__)}/../lib"
  when 5
    require 'rubygems'
  when 6
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
