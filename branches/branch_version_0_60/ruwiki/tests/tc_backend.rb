# 	Copyright (c)2002, Digikata
# 	Author: Alan Chen (alan@digikata.com)	
# 		
# 	$Id$	
#   License: same as ruby

require 'test/unit'
require 'test_utils.rb'
require 'rw_config.rb'

class Test_Backend_Text < Test::Unit::TestCase
  include Test_Utils
  
  def set_up
    # The $backend variable should be setup now
    @page_topic   = 'TestPageBackend'
    @page_proj    = 'Default'
    
    page_rawtext = "id: 0
topic: #{@page_topic}
#EHDR
Test page for unit test.
"

    testing_page(:set_up, @page_topic, page_rawtext)
    Backend.setup(:flatfiles)

    but = '../data/Backend_Unit_Test'
    Dir.rmdir(but) if FileTest.exist?(but)

    file = '../data/Default/NoTopic'
    File.unlink(file) if FileTest.exist?(file)
    
    @txtback = Backend::Back_Flatfile.new($rw_paths.data)
  end

  def tear_down
    testing_page(:tear_down, @page_topic)    
  end
  
  # check retreive (somewhat redundant, tc_page does this more extensively)
  def test_01
    page = @txtback.retreive(@page_topic, @page_proj)

    assert_equal(@page_topic, page.topic)
    assert_equal(@page_proj,  page.project)
    assert_instance_of(Ruwiki::Page,page)
  end

  # check exist?
  def test_02
    assert_equal("/var/www/dev/ruwiki/data/#{@page_proj}/#{@page_topic}",
                 @txtback.pagefile(@page_topic,@page_proj))
    
    assert(@txtback.project_exists?(@page_proj))
    assert(@txtback.page_exists?(@page_topic, @page_proj))
    assert(!@txtback.page_exists?('ShouldNotExist', @page_proj))
  end

  # check project create and destroy
  def test_03
    but = 'Backend_Unit_Test'
    assert_equal(false, @txtback.project_exists?(but))
    @txtback.create_project(but)
    assert(@txtback.project_exists?(but))
    @txtback.destroy_project(but)
    assert_equal(false, @txtback.project_exists?(but))
  end

  # page create and destroy
  def test_04
    topic = 'NoTopic'
    project = 'Default'

    assert_equal(false, @txtback.page_exists?(topic,project))
    
    page = Ruwiki::Page.new(:topic   => topic,
                            :content => 'none',
                            :pg_id   => 1000,
                            :project => project)
                            
    @txtback.store(page)
    assert(@txtback.page_exists?(topic,project))
    assert(@txtback.page_exists?(page.topic,page.project))

    @txtback.destroy(page)
    assert_equal(false, @txtback.page_exists?(topic,project))
    assert_equal(false, @txtback.page_exists?(page.topic,page.project))
  end


  # retreive a non-existent page
  def test_05
    topic = 'NonExistent'
    project = 'Default'

    # prereq - page shouldn't exist yet
    assert_equal(false, @txtback.page_exists?(topic,project))

    page = @txtback.retreive(topic,project)
    assert_equal(false, @txtback.page_exists?(topic,project))
    @txtback.store(page)
    assert_equal(true, @txtback.page_exists?(topic,project))
    @txtback.destroy(page)
    assert_equal(false, @txtback.page_exists?(topic,project))
  end

  
  # page rename
  # list projects  
end

