#!/usr/bin/env ruby
#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

  # Customize this if you put the RuWiki files in a different location.
$LOAD_PATH.unshift("../lib")

require 'ruwiki'
require 'test/unit'

class Test_Backend_Flat
end


begin
  rw = Ruwiki.new
    # Configuration defaults to certain values. This overrides the defaults.

    # Configure the URL to the Wiki.
  rw.config.url             = "http://domain.com/"
    # The webmaster.
  rw.config.webmaster       = "webmaster@domain.com"

    # This should ensure that the CGI is always appropriately named
  rw.config.cgi             = __FILE__

# rw.config.debug           = false
# rw.config.title           = "Ruwiki"
# rw.config.default_page    = "DefaultPage"
# rw.config.default_project = "Default"
# rw.config.storage_type    = :flatfiles
# rw.config.data_path       = "./data/"
# rw.config.css             = "ruwiki.css"

  rw.config.verify

  rw.set_backend
  rw.set_page
  rw.process_page
  rw.output
rescue => e
  rw.cgi.out do
    rw.cgi.html do
      "\n" +
      rw.cgi.head do
        [ "", rw.cgi.title { "Error - #{rw.config.title}" }, rw.config.css_link, "" ].join("\n")
      end + "\n" +
      rw.cgi.body { "<h1>#{e}</h1><p>#{e.backtrace.join("\n")}" }
    end
  end
end
