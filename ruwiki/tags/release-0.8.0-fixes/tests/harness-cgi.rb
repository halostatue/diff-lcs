#!/usr/bin/env ruby
#--
# Ruwiki version 0.8.0
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
require 'harness'

ENV["REQUEST_METHOD"] = "HEAD"


  # This is the CGI version of Ruwiki. Therefore, when we create the Ruwiki
  # instance, we specify that the request and response handlers are to be
  # generated from a new CGI object.
$wiki = Ruwiki.new(Ruwiki::Handler.from_cgi(CGI.new))

  # Configuration defaults to certain values. This overrides the defaults.
  # The webmaster.
$wiki.config.webmaster = "webmaster@domain.com"
$wiki.config.storage_type = :flatfiles
$wiki.config.storage_options[:flatfiles][:data_path] = "../data"
$wiki.config.storage_options[:flatfiles][:extension] = "ruwiki"
$wiki.config.template_path = "../templates/"
$wiki.config.verify
$wiki.set_backend

# $wiki.config.debug           = false
# $wiki.config.title           = "Ruwiki"
# $wiki.config.default_page    = "ProjectIndex"
# $wiki.config.default_project = "Default"
# $wiki.config.storage_type    = :flatfiles
# $wiki.config.storage_options[:flatfiles][:data_path] = "./data/"
# $wiki.config.template_path   = "./templates/"
# $wiki.config.template_set    = "default"
# $wiki.config.css             = "ruwiki.css"
