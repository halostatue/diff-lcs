@echo off
if "%OS%" == "Windows_NT" goto WinNT
ruby -x "ruwiki_servlet.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofruby
ruby -x "ruwiki_servlet.bat" %*
:WinNT
goto endofruby
#!/usr/bin/env ruby
#--
# Ruwiki version 0.6.1
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

  # Customize this if you put the RuWiki files in a different location.
$LOAD_PATH.unshift("lib")

require 'webrick'
require 'getopts'
require 'ruwiki'
require 'ruwiki/servlet'

getopts "", 'p:8808'

  # This is for the WEBrick version of Ruwiki. This has been abstracted to
  # accept a $config global variable to reconfigure Ruwiki after initial
  # creation.
$config = Ruwiki::Config.new

  # Configuration defaults to certain values. This overrides the defaults.
  # The webmaster.
$config.webmaster       = "webmaster@domain.com"

# $config.debug           = false
# $config.title           = "Ruwiki"
# $config.default_page    = "DefaultPage"
# $config.default_project = "Default"
# $config.storage_type    = :flatfiles
# $config.storage_options[:flatfiles][:data_path] = "./data/"
# $config.storage_options[:flatfiles][:extension] = nil
# $config.css             = "ruwiki.css"
# $config.template_file   = nil

logger = WEBrick::Log::new($stderr, WEBrick::Log::DEBUG)

s = WEBrick::HTTPServer.new(
                            :Port => $OPT_p.to_i,
                            :StartThreads => 1,
                            :Logger => logger
                            )

s.mount("/", Ruwiki::Servlet)
trap("INT") { s.shutdown; exit }
s.start
__END__
:endofruby
