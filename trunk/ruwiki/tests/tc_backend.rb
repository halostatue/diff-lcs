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
require 'harness'
require 'ruwiki/backend/flatfiles'
require 'ostruct'
require 'test/unit'
require 'fileutils'

class TC_Backend_Flatfile < Test::Unit::TestCase
  def setup
    @ffopts = { :data_path => "./test/data" }

    # generate a database
    if( File.exists?( @ffopts[:data_path] ) )
      raise "Setup Error: #{@ffopts[:data_path]} exists"
    end
    @flatbase = { 'Proj1' => ['P1TopicOne:this is the content', 
                             'P1TopicTwo:more content'],
                 'Proj2' => ['P2TopicOne:this is the content', 
                             'P2TopicTwo:more content']
    }
    
    @flatbase.each do |key,val|
      prjdir = @ffopts[:data_path] + "/#{key}"
      FileUtils.mkdir_p(prjdir)
      val.each do |topcon|
        topic,content = topcon.split(":")
        File.open(prjdir + "/" + topic, 'w') { |fh| fh.puts content }
      end
    end

    @backend = nil
    @pg = nil
  end

  def teardown
    # remove testing flatabase
    FileUtils.rm_rf( @ffopts[:data_path] )
    Dir.rmdir("./test") # ugly but it works
  end

  def test_list_projects
    assert_nothing_raised do
      @backend = ::Ruwiki::Backend::Flatfiles.new(@ffopts)
    end

    # should be ['Proj1', 'Proj2']
    assert_equal( @flatbase.keys, @backend.list_projects )
  end

  def test_list_topics
    assert_nothing_raised do
      @backend = ::Ruwiki::Backend::Flatfiles.new(@ffopts)
    end

    @flatbase.keys.sort.each do |proj|
      got_topics = @backend.list_topics( proj )
      exp_topics = @flatbase[proj].map { |ent| ent.split(':')[0] }
      assert_equal( exp_topics, got_topics )
    end
  end

  # test simple one word lookups
  # need to add more complex cases
  def test_search_project
    assert_nothing_raised do
      @backend = ::Ruwiki::Backend::Flatfiles.new(@ffopts)
    end

    assert_equal( { 'P1TopicOne'=>1, 'P1TopicTwo'=>0 }, @backend.search_project('Proj1', 'this')    )
    assert_equal( { 'P1TopicOne'=>0, 'P1TopicTwo'=>1 }, @backend.search_project('Proj1', 'more')    )
    assert_equal( { 'P1TopicOne'=>1, 'P1TopicTwo'=>1 }, @backend.search_project('Proj1', 'topic')   )
    assert_equal( { 'P1TopicOne'=>1, 'P1TopicTwo'=>1 }, @backend.search_project('Proj1', 'content') )
  end
end
