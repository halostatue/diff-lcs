#!/usr/bin/env ruby

puts "Checking for test cases:"
Dir['tc*.rb'].each do |testcase|
  puts "\t#{testcase}"
  require testcase
end
puts " "
