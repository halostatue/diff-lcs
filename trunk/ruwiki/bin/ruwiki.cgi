#!/usr/bin/env ruby
#--
# Ruwiki version 0.8.0
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
    require_gem 'ruwiki'
  else
    require 'ruwiki'
  end
rescue LoadError
  load_state += 1

  if load_state < 4
    $LOAD_PATH.unshift "#{RuwikiInstaller::PATH}/../lib" if load_state == 3
    retry
  else
    raise
  end
end

  # This is the CGI version of Ruwiki. Therefore, when we create the Ruwiki
  # instance, we specify that the request and response handlers are to be
  # generated from a new CGI object.
wiki = Ruwiki.new(Ruwiki::Handler.from_cgi(CGI.new))

config_file = File.join(Dir.pwd, Ruwiki::Config::CONFIG_NAME)

if File.exists?(config_file)
  wiki.load_config(config_file)
  config = Ruwiki::Config.read(config_file)
  if config.webmaster.nil? or config.rc.webmaster.empty?
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
    # This next defaults to :flatfiles. Conversion of the default data
    # will be necessary to use other formats.
# wiki.config.storage_type    = :flatfiles
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
