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
ENV["REQUEST_METHOD"] = "HEAD"

require 'ruwiki'

  # This is the CGI version of Ruwiki. Therefore, when we create the Ruwiki
  # instance, we specify that the request and response handlers are to be
  # generated from a new CGI object.
$wiki = Ruwiki.new(Ruwiki::Handler.from_cgi(CGI.new))

  # Configuration defaults to certain values. This overrides the defaults.
  # The webmaster.
$wiki.config.webmaster = "webmaster@domain.com"
$wiki.config.storage_type = 'flatfiles'

dp = nil
dp = "../data" if File.exists?("../data")
dp = "./data" if File.exists?("./data")
raise "Cannot find either ./data or ../data for tests. Aborting." if dp.nil?

$wiki.config.storage_options['flatfiles']['data-path'] = dp
$wiki.config.storage_options['flatfiles']['format'] = "exportable"
$wiki.config.storage_options['flatfiles']['extension'] = "ruwiki"

tp = nil
tp = "../templates" if File.exists?("../templates")
tp = "./templates" if File.exists?("./templates")
raise "Cannot find either ./templates or ../templates for tests. Aborting." if tp.nil?

$wiki.config.template_path = tp
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
