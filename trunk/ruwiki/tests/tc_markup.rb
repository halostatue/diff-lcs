#!/usr/bin/ruby
#
# look at c2t.rb for test scaffolding
# $LOAD_PATH.unshift('') # place code into load path
#
require 'test/unit'
require 'rw_config.rb'

class Test_Wiki_Markup < Test::Unit::TestCase

  def set_up
    $backend = Backend::Back_Flatfile.new($rw_paths.data)
    @mw = Markup::Wiki.new($backend)
    @sample_page01 = "This is a sample page
SampleLink
External link http://digikata.com
"
    @sample_page01_links  = ['SampleLink']
    @sample_page01_elinks = ['http://digikata.com']
  end

  def tear_down
    @mw = nil
  end
  
  def test__misc_fragments
    fragments = [
      ['* listitem',  '<ul><li>listitem</li></ul>'],
      ['# listitem', '<ol><li>listitem</li></ol>'],
      ["\n \nHallo",  "<p>Hallo"],
      ['----',        "<hr>"],
      ['11\11\2002',  '11\11\2002'],
      ['TestPage',    %Q(TestPage<a class="rw_pagelink" href="ruwiki.cgi?action=edit&TestPage">?</a>)]
    ]

    fragments.each { |frag|
      rawtext, extransformed, exparsedata = frag
      transformed, parsedata = @mw.parse(rawtext)
      assert_equal(extransformed, transformed)
      assert_equal(exparsedata, parsedata) if( exparsedata != nil )
    }
  end

  def test__ordered_list_concat
    content = "* item1\n* item2"
    tfm, pd = @mw.parse(content)
    assert_equal(%Q(<ul><li>item1</li><li>item2</li></ul>), tfm)
  end
  
  def test_01
    content = "TestPage"
    expected = %Q(TestPage<a class="rw_pagelink" href="ruwiki.cgi?action=edit&TestPage">?</a>)
    newcontent, parsedata = @mw.parse(content)
    assert_equal(expected, newcontent)
    assert_equal(['TestPage'], parsedata.links)
  end

  def test_02
    extlink = 'http://127.0.0.1/hallo/TestPage'
    content = <<ECON
#{extlink}
TestPage
SampleLink
ECON

    expected = %Q(<a class="rw_extlink" href="#{extlink}">#{extlink}</a>
TestPage<a class="rw_pagelink" href="ruwiki.cgi?action=edit&TestPage">?</a>
SampleLink<a class="rw_pagelink" href="ruwiki.cgi?action=edit&SampleLink">?</a>
)

    newcontent, parsedata = @mw.parse(content)
    assert_equal(expected, newcontent)
    assert_equal([extlink],    parsedata.elinks)
    assert_equal(['TestPage','SampleLink'], parsedata.links )
  end

  def test_03
    newcontent, parsedata = @mw.parse(@sample_page01)    
    assert_equal(@sample_page01_links,  parsedata.links)
    assert_equal(@sample_page01_elinks, parsedata.elinks)
  end

  
end
