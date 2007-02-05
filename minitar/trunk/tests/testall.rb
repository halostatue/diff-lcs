#!/usr/bin/env ruby
#--
# Ruwiki version 0.8.0
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0

puts "Checking for test cases:"
Dir['tc*.rb'].each do |testcase|
  puts "\t#{testcase}"
  require testcase
end
puts " "
