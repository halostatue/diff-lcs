#!/usr/bin/ruby
#
# look at c2t.rb for test scaffolding
# $LOAD_PATH.unshift('') # place code into load path
#
require 'test/unit'
require 'test_utils.rb'
require 'rw_config.rb'

class Test_Page < Test::Unit::TestCase
  include Test_Utils
  
  def set_up
    @sample_page01 = "id: 1
topic: SamplePage
#EHDR
This is a sample page
SampleLink
External link http://digikata.com
"
    testing_page(:set_up)
  end

  def tear_down
    testing_page(:tear_down)
  end
  
  def test_01
    page = Ruwiki.process(@sample_page01)

    assert_equal(Ruwiki::Page,   page.class)
    assert_equal(1,              page.pg_id)
    assert_equal('SamplePage',   page.topic)
    assert_equal(['SampleLink'], page.links)
    assert_equal(['http://digikata.com'], page.ext_links)
  end

  def test_02
    page = Ruwiki::Page.new
    page.topic = 'NewTopic'
    page.pg_id = '1000'
    page.content = 'none'

    assert_equal("id: 1000
topic: NewTopic
#EHDR
none", page.to_s)
  end

  def test_03
    page = $backend.retreive('TestPage','Default')
    assert_equal(0, page.pg_id)
  end

  def test_04
    page = Ruwiki::Page.new
    page.topic = 'TestPage1'
    page.pg_id = 1000
    page.content = 'none'
    page.project = 'Default'
    $backend.store(page)

    goodname = '../data/Default/TestPage1'
    assert(FileTest.exist?(goodname))
    File.unlink(goodname)
  end
end
