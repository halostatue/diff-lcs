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

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0

require 'harness'
require 'ruwiki/backend/flatfiles'
require 'ostruct'
require 'test/unit'

# see if we can reproduce the LicenseandAuthor hang
# described in bug id 147 on rubyforge
class TC_LicenseAndAuthorHang < Test::Unit::TestCase
  def setup
    @ffopts = { }
    dp = nil
    dp = "../data" if File.exists?("../data")
    dp = "./data" if File.exists?("./data")
    raise "Cannot find either ./data or ../data for tests. Aborting." if dp.nil?

    @ffopts['data-path'] = dp
    @ffopts['format'] = 'exportable'

    @backend = nil
    @pg = nil
  end

  # load "to the metal"
  def test_ffload
    assert_nothing_raised do
      @backend = ::Ruwiki::Backend::Flatfiles.new(@ffopts)
    end
    assert_not_nil(@backend)
    assert_nothing_raised do
      @pg = @backend.load('LicenseAndAuthorInfo.ruwiki', 'Ruwiki')
    end
    assert_not_nil(@pg)
  end

  # abstract backend retreive
  def test_beload
    @backend = nil
    assert_nothing_raised do
      mock_ruwiki = OpenStruct.new
      mock_ruwiki.config = OpenStruct.new
      mock_ruwiki.config.message = {}
      mock_ruwiki.config.storage_options = { 'flatfiles' => @ffopts }

      @backend = ::Ruwiki::BackendDelegator.new(mock_ruwiki, 'flatfiles')
    end
    assert_not_nil(@backend)
    assert_nothing_raised do
      @pg = @backend.retrieve('LicenseAndAuthorInfo', 'Ruwiki')
    end
    assert_not_nil(@pg)
  end
end

# if __FILE__ == $0
#   ObjectSpace.each_object { |o| tests << o if o.kind_of?(Class) } 
#   tests.delete_if { |o| !o.ancestors.include?(Test::Unit::TestCase) }
#   tests.delete_if { |o| o == Test::Unit::TestCase }

#   tests.each { |test| Test::Unit::UI::Console::TestRunner.run(test) }
# end
