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

  # So that Ruwiki doesn't have to be loaded in full to use the bloody thing.
unless defined?(Ruwiki)
  class Ruwiki
    VERSION = "0.8.1"
  end
end

module Ruwiki::Utils
  RUN_PATH = Dir.pwd
end
