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

# see if we can reproduce the LicenseandAuthor hang
# described in bug id 147 on rubyforge
class TC_LicenseAndAuthorHang < Test::Unit::TestCase
  def setup
    @ffopts = { :data_path => "../data" }
    @storage_opts = {}
    @storage_opts[:flatfiles] = @ffopts
  end

  # load "to the metal"
  def test_ffload
    ffbackend = ::Ruwiki::Backend::Flatfiles.new(@ffopts)
    pg = ffbackend.load('LicenseAndAuthorInfo', 'Ruwiki')
    assert( pg != nil )
  end

  # abstract backend retreive
  def test_beload
    mock_ruwiki = Object.new
    class << mock_ruwiki 
      attr_accessor :config
    end

    mock_config = Object.new
    mock_ruwiki.config = mock_config

    class << mock_config
      attr_accessor :message
      attr_accessor :storage_options
    end
    mock_config.message         = Object.new
    mock_config.storage_options = { :flatfiles => @ffopts }

    backend = ::Ruwiki::BackendDelegator.new(mock_ruwiki, :flatfiles)
    assert( backend != nil )

    pg = backend.retrieve('LicenseAndAuthorInfo', 'Ruwiki')
    assert( pg != nil )
  end
end
