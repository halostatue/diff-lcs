#!/usr/bin/env ruby
#--
# Ruwiki version 0.6.x
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
require 'test/unit'
require 'harness'
require 'ruwiki/backend/flatfiles'
require 'ostruct'

# see if we can reproduce the LicenseandAuthor hang
# described in bug id 147 on rubyforge
class TC_LicenseAndAuthorHang < Test::Unit::TestCase
  def setup
    @ffopts = { :data_path => "../data" }

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
      @pg = @backend.load('LicenseAndAuthorInfo', 'Ruwiki')
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
      mock_ruwiki.config.storage_options = { :flatfiles => @ffopts }

      @backend = ::Ruwiki::BackendDelegator.new(mock_ruwiki, :flatfiles)
    end
    assert_not_nil(@backend)
    assert_nothing_raised do
      @pg = @backend.retrieve('LicenseAndAuthorInfo', 'Ruwiki')
    end
    assert_not_nil(@pg)
  end
end
