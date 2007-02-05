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

  # This is the CGI version of Ruwiki. Therefore, when we create the Ruwiki
  # instance, we specify that the request and response handlers are to be
  # generated from a new CGI object.
wiki = Ruwiki.new(Ruwiki::Handler.from_cgi(CGI.new))

config_file = File.join(Dir.pwd, Ruwiki::Config::CONFIG_NAME)

if File.exists?(config_file)
  wiki.load_config(config_file)
  config = Ruwiki::Config.read(config_file)
  if config.webmaster.nil? or config.webmaster.empty?
    config.webmaster = "webmaster@domain.tld"
  end
else
    # Configuration defaults to certain values. This overrides the defaults.
    # The webmaster.
  wiki.config.webmaster       = "webmaster@domain.tld"

# wiki.config.debug           = false
# wiki.config.title           = "Ruwiki"
# wiki.config.default_page    = "ProjectIndex"
# wiki.config.default_project = "Default"
    # This next defaults to 'flatfiles'. Conversion of the default data will
    # be necessary to use other formats.
# wiki.config.storage_type    = 'flatfiles'
# wiki.config.storage_options[wiki.config.storage_type][:data_path] = "./data/"
  wiki.config.storage_options[wiki.config.storage_type][:extension] = "ruwiki"
# wiki.config.template_path   = "./templates/"
# wiki.config.template_set    = "default"
# wiki.config.css             = "ruwiki.css"
# wiki.config.time_format     = "%H:%M:%S"
# wiki.config.date_format     = "%Y.%m.%d"
# wiki.config.datetime_format = "%Y.%m.%d %H:%M:%S"
end

wiki.config!
wiki.run
