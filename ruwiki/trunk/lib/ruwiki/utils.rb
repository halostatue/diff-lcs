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

  # So that Ruwiki doesn't have to be loaded in full to use the bloody thing.
unless defined?(Ruwiki)
  class Ruwiki
    VERSION = "0.9.0"
  end
end

module Ruwiki::Utils
  RUN_PATH = Dir.pwd
end
