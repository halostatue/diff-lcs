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

  # Customize this if you put the RuWiki files in a different location.
begin
  require 'ruwiki'
rescue LoadError
  $LOAD_PATH.unshift "#{File.dirname($0)}/lib"
  require 'ruwiki'
end

  # This is the CGI version of Ruwiki. Therefore, when we create the Ruwiki
  # instance, we specify that the request and response handlers are to be
  # generated from a new CGI object.
wiki = Ruwiki.new(Ruwiki::Handler.from_cgi(CGI.new))

  # Configuration defaults to certain values. This overrides the defaults.
  # The webmaster.
wiki.config.webmaster       = "webmaster@domain.com"

# wiki.config.debug           = false
# wiki.config.title           = "Ruwiki"
# wiki.config.default_page    = "ProjectIndex"
# wiki.config.default_project = "Default"
  # This next defaults to :flatfiles for Ruby 1.8.1 or earlier and to :yaml for
  # Ruby 1.8.2 or later.
# wiki.config.storage_type    = :flatfiles
# wiki.config.storage_options[wiki.config.storage_type][:data_path] = "./data/"
wiki.config.storage_options[wiki.config.storage_type][:extension] = "ruwiki"
# wiki.config.template_path   = "./templates/"
# wiki.config.template_set    = "default"
# wiki.config.css             = "ruwiki.css"
# wiki.config.time_format     = "%H:%M:%S"
# wiki.config.date_format     = "%Y.%m.%d"
# wiki.config.datetime_format = "%Y.%m.%d %H:%M:%S"
wiki.config = wiki.config

wiki.run
