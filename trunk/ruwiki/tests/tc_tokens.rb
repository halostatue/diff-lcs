#!/usr/bin/env ruby
#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0

require 'test/unit'
require 'harness'

class TokenTestCases < Test::Unit::TestCase
  def setup
    @mrw = MockRuwiki.new
  end

  class MockRuwiki
    def initialize
      @project  = "Default"
      @tokens   = []
      @script   = "<uri>"
      @message  = Hash.new { |h, k| h[k] = "#{k.inspect}" }
      @title    = "Ruwiki"
    end

    def __tokenize(content, token)
      content.gsub!(token.regexp) do |m|
        match = Regexp.last_match
        tc    = token.new(match, @project, $wiki.backend, @script, @message, @title)
        @tokens << tc
        if m[0, 1] == '\\'
          "\\TOKEN_#{@tokens.size - 1}"
        else
          "TOKEN_#{@tokens.size - 1}"
        end
      end
      content
    end

    def __replace(content)
      replaced = []
      s = true
      loop do
        break if replaced.size >= @tokens.size
        break if s.nil?
        s = content.gsub!(/\\TOKEN_(\d+)/) do |m|
          match = Regexp.last_match
          i = match.captures[0].to_i
          replaced << i
          @tokens[i].restore
        end

        s = content.gsub!(/TOKEN_(\d+)/) do |m|
          match = Regexp.last_match
          i = match.captures[0].to_i
          replaced << i
          @tokens[i].replace
        end
      end
      content
    end

    def __post_replace(content)
      token_classes = @tokens.map { |token| token.class }.sort_by { |token| token.rank }
      token_classes.uniq.each { |tc| tc.post_replace(content) }
      content
    end

  end

  def __process(token, content, tokenized, replaced, result)
    assert_equal(tokenized, content = @mrw.__tokenize(content, token), "Tokenization failure.")
    assert_equal(replaced, content = @mrw.__replace(content), "Replacement failure.")
    assert_equal(result, content = @mrw.__post_replace(content), "Post-replace failure.")
  end

  def __display(token, content)
    p tokenized = @mrw.__tokenize(content.dup, token)
    p replaced  = @mrw.__replace(tokenized.dup)
    p result    = @mrw.__post_replace(replaced.dup)
  end

  def test_Paragraph
    token   = Ruwiki::Wiki::Paragraph
    content = "\nABC\n\nabc\n"
    tkv     = "TOKEN_0\nABC\nTOKEN_1\nabc\n"
    rpv     = %Q(</p><p class="rwtk_Paragraph">\nABC\n</p><p class="rwtk_Paragraph">\nabc\n)
    res     = %Q(<p class="rwtk_Paragraph">ABC</p>\n<p class="rwtk_Paragraph">abc</p>)

    __process(token, content, tkv, rpv, res)
  end

  def test_Image
    token   = Ruwiki::Wiki::Image
    content = "[image:http://www.halostatue.ca/graphics/maple_leaf.gif]"
    tkv     = "TOKEN_0"
    rpv     = %Q(<img class="rwtk_Image" alt="http://www.halostatue.ca/graphics/maple_leaf.gif" src="http://www.halostatue.ca/graphics/maple_leaf.gif" title="http://www.halostatue.ca/graphics/maple_leaf.gif" />)
    res     = rpv

    __process(token, content, tkv, rpv, res)

    tkv     = "TOKEN_1"
    content = %Q([image : http://www.halostatue.ca/graphics/maple_leaf.gif style="border: 1px solid black" title="Maple Leaf"])
    rpv     = %Q(<img class="rwtk_Image" alt="Maple Leaf" src="http://www.halostatue.ca/graphics/maple_leaf.gif" style="border: 1px solid black" title="Maple Leaf" />)
    res     = rpv
    __process(token, content, tkv, rpv, res)

    tkv     = "TOKEN_2"
    content = %Q([image: http://www.halostatue.ca/graphics/maple_leaf.gif style="border: 1px solid black" numbered=true])
    rpv     = %Q(<img class="rwtk_Image" alt="[1]" src="http://www.halostatue.ca/graphics/maple_leaf.gif" style="border: 1px solid black" title="[1]" />)
    res     = rpv
    __process(token, content, tkv, rpv, res)

    tkv     = "TOKEN_3"
    content = %Q([image: http://www.halostatue.ca/graphics/maple_leaf.gif style="border: 1px solid black" numbered=true alt="Maple Leaf"])
    rpv     = %Q(<img class="rwtk_Image" alt="Maple Leaf" src="http://www.halostatue.ca/graphics/maple_leaf.gif" style="border: 1px solid black" title="[2]" />)
    res     = rpv
    __process(token, content, tkv, rpv, res)

    content = "\[image:http://www.halostatue.ca/graphics/maple_leaf.gif]"
    tkv     = "TOKEN_4"
    rpv     = content
    res     = content

    __process(token, content, tkv, rpv, res)
  end

  def test_Code
    content = "  line 1\n    line 2\nline 3\n"
    token   = Ruwiki::Wiki::Code
    tkv     = "TOKEN_0TOKEN_1line 3\n"
    rpv     = %Q(</p><pre class="rwtk_Code">  line 1</pre>\n</p><pre class="rwtk_Code">    line 2</pre>\nline 3\n)
    res     = %Q(</p><pre class="rwtk_Code">  line 1\n    line 2</pre>\nline 3\n)

    __process(token, content, tkv, rpv, res)

    content = "  line 1\n    line 2\n  \n\nline 3\n"
    token   = Ruwiki::Wiki::Code
    tkv     = "TOKEN_2TOKEN_3TOKEN_4\nline 3\n"
    rpv     = %Q(</p><pre class="rwtk_Code">  line 1</pre>\n</p><pre class="rwtk_Code">    line 2</pre>\n</p><pre class="rwtk_Code">  </pre>\n\nline 3\n)
    res     = %Q(</p><pre class="rwtk_Code">  line 1\n    line 2\n  </pre>\n\nline 3\n)

    __process(token, content, tkv, rpv, res)
  end

  def test_NumberedLinks
    token   = Ruwiki::Wiki::NumberedLinks
    Ruwiki::Wiki::NumberedLinks.reset
    content = "[http://www.ruby-lang.org] \\[http://www.rubyforge.org]"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = %Q{<a class="rwtk_NumberedLinks" href="http://www.google.com/url?sa=D&q=http://www.ruby-lang.org">[1]</a> [http://www.rubyforge.org]}
    res     = %Q{<a class="rwtk_NumberedLinks" href="http://www.google.com/url?sa=D&q=http://www.ruby-lang.org">[1]</a> [http://www.rubyforge.org]}

    __process(token, content, tkv, rpv, res)
  end

  def test_NamedLinks
    token   = Ruwiki::Wiki::NamedLinks
    content = "[http://www.ruby-lang.org Ruby] \\[http://www.rubyforge.org RubyForge]"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = %Q{<a class="rwtk_NamedLinks" href="http://www.google.com/url?sa=D&q=http://www.ruby-lang.org">Ruby</a> [http://www.rubyforge.org RubyForge]}
    res     = %Q{<a class="rwtk_NamedLinks" href="http://www.google.com/url?sa=D&q=http://www.ruby-lang.org">Ruby</a> [http://www.rubyforge.org RubyForge]}

    __process(token, content, tkv, rpv, res)
  end

  def test_ExternalLinks
    token   = Ruwiki::Wiki::ExternalLinks
    content = "http://www.ruby-lang.org \\http://www.rubyforge.org"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = %Q{<a class="rwtk_ExternalLinks" href="http://www.google.com/url?sa=D&q=http://www.ruby-lang.org">http://www.ruby-lang.org</a> http://www.rubyforge.org}
    res     = %Q{<a class="rwtk_ExternalLinks" href="http://www.google.com/url?sa=D&q=http://www.ruby-lang.org">http://www.ruby-lang.org</a> http://www.rubyforge.org}

    __process(token, content, tkv, rpv, res)
  end

  def test_HRule
    token   = Ruwiki::Wiki::HRule
    content = "----\n\\----"
    tkv     = "TOKEN_0\n\\TOKEN_1"
    rpv     = %Q(<hr class="rwtk_HRule" />\n----)
    res     = %Q(<hr class="rwtk_HRule" />\n----)

    __process(token, content, tkv, rpv, res)
  end

  def test_ProjectCrossLink
    token   = Ruwiki::Wiki::ProjectCrossLink
    content = "Ruwiki::ChangeLog \\Ruwiki::To_Do Ruwiki::NotExist \\Ruwiki::NotExist"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3"
    rpv     = %Q{<a class="rwtk_WikiLink" href="<uri>/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::To_Do <span class="rwtk_EditWikiLink">Ruwiki::NotExist</span><a class="rwtk_WikiLink" href="<uri>/Ruwiki/NotExist/_edit">?</a> Ruwiki::NotExist}
    res     = %Q{<a class="rwtk_WikiLink" href="<uri>/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::To_Do <span class="rwtk_EditWikiLink">Ruwiki::NotExist</span><a class="rwtk_WikiLink" href="<uri>/Ruwiki/NotExist/_edit">?</a> Ruwiki::NotExist}

    __process(token, content, tkv, rpv, res)
  end

  def test_ProjectCrossLinkWikipedia
    token   = Ruwiki::Wiki::ProjectCrossLinkWikipedia
    content = "Ruwiki::[[ChangeLog]] \\Ruwiki::[[To_Do]] Ruwiki::[[Does Not Exist]] \\Ruwiki::[[Does Not Exist]] Ruwiki::[[_invalid]]"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 Ruwiki::[[_invalid]]"
    rpv     = %Q{<a class="rwtk_WikiLink" href="<uri>/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::[[To_Do]] <span class="rwtk_EditWikiLink">Ruwiki::Does Not Exist</span><a class="rwtk_WikiLink" href="<uri>/Ruwiki/Does+Not+Exist/_edit">?</a> Ruwiki::[[Does Not Exist]] Ruwiki::[[_invalid]]}
    res     = %Q{<a class="rwtk_WikiLink" href="<uri>/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::[[To_Do]] <span class="rwtk_EditWikiLink">Ruwiki::Does Not Exist</span><a class="rwtk_WikiLink" href="<uri>/Ruwiki/Does+Not+Exist/_edit">?</a> Ruwiki::[[Does Not Exist]] Ruwiki::[[_invalid]]}

    __process(token, content, tkv, rpv, res)
  end

  def test_ProjectIndex
    token   = Ruwiki::Wiki::ProjectIndex
    content = "::Ruwiki \\::Ruwiki ::Newproject \\::Newproject"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3"
    rpv     = %Q{<a class="rwtk_WikiLink" href="<uri>/Ruwiki/ProjectIndex">Ruwiki</a> ::Ruwiki <span class="rwtk_EditWikiLink">Newproject</span><a class="rwtk_WikiLink" href="<uri>/Newproject/_create">?</a> ::Newproject}
    res     = %Q{<a class="rwtk_WikiLink" href="<uri>/Ruwiki/ProjectIndex">Ruwiki</a> ::Ruwiki <span class="rwtk_EditWikiLink">Newproject</span><a class="rwtk_WikiLink" href="<uri>/Newproject/_create">?</a> ::Newproject}

    __process(token, content, tkv, rpv, res)
  end

  def test_WikiLinks
    token   = Ruwiki::Wiki::WikiLinks
    content = "ProjectIndex \\ProjectIndex AustinZiegler \\AustinZiegler Alan_Chen \\Alan_Chen"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 TOKEN_4 \\TOKEN_5"
    rpv     = %Q{<a class="rwtk_WikiLink" href="<uri>/Default/ProjectIndex">ProjectIndex</a> ProjectIndex <span class="rwtk_EditWikiLink">AustinZiegler</span><a class="rwtk_WikiLink" href="<uri>/Default/AustinZiegler/_edit">?</a> AustinZiegler <span class="rwtk_EditWikiLink">Alan Chen</span><a class="rwtk_WikiLink" href="<uri>/Default/Alan_Chen/_edit">?</a> Alan_Chen}
    res     = %Q{<a class="rwtk_WikiLink" href="<uri>/Default/ProjectIndex">ProjectIndex</a> ProjectIndex <span class="rwtk_EditWikiLink">AustinZiegler</span><a class="rwtk_WikiLink" href="<uri>/Default/AustinZiegler/_edit">?</a> AustinZiegler <span class="rwtk_EditWikiLink">Alan Chen</span><a class="rwtk_WikiLink" href="<uri>/Default/Alan_Chen/_edit">?</a> Alan_Chen}

    __process(token, content, tkv, rpv, res)
  end

  def test_WikipediaLinks
    token   = Ruwiki::Wiki::WikipediaLinks
    content = "[[ProjectIndex]] \\[[ProjectIndex]] [[Austin Ziegler]] \\[[Austin Ziegler]] [[_Alan Chen]]"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 [[_Alan Chen]]"
    rpv     = %Q{<a class="rwtk_WikiLink" href="<uri>/Default/ProjectIndex">ProjectIndex</a> [[ProjectIndex]] <span class="rwtk_EditWikiLink">Austin Ziegler</span><a class="rwtk_WikiLink" href="<uri>/Default/Austin+Ziegler/_edit">?</a> [[Austin Ziegler]] [[_Alan Chen]]}
    res     = %Q{<a class="rwtk_WikiLink" href="<uri>/Default/ProjectIndex">ProjectIndex</a> [[ProjectIndex]] <span class="rwtk_EditWikiLink">Austin Ziegler</span><a class="rwtk_WikiLink" href="<uri>/Default/Austin+Ziegler/_edit">?</a> [[Austin Ziegler]] [[_Alan Chen]]}

    __process(token, content, tkv, rpv, res)
  end

  def test_Abbreviations
    token   = Ruwiki::Wiki::Abbreviations
    content = "@{matz}\n@{}\n\\@{matz}"
    tkv     = "TOKEN_0\nTOKEN_1\n\\TOKEN_2"
    rpv     = %Q(Yukihiro Matsumoto\n<dl class="rwtk_Abbreviations"><dt class="rwtk_Abbreviations">matz</dt><dd class="rwtk_Abbreviations">Yukihiro Matsumoto</dd></dl>\n@{matz})
    res     = %Q(Yukihiro Matsumoto\n<dl class="rwtk_Abbreviations"><dt class="rwtk_Abbreviations">matz</dt><dd class="rwtk_Abbreviations">Yukihiro Matsumoto</dd></dl>\n@{matz})

    __process(token, content, tkv, rpv, res)
  end

  def test_Headings
    token   = Ruwiki::Wiki::Headings
    content = "= header 1\n== header 2\n=== header 3\n==== header 4\n===== header 5\n====== header 6\n======= header 7->6\n\\== noheader 2\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\nTOKEN_4\nTOKEN_5\nTOKEN_6\n\\TOKEN_7\n"
    rpv     = %Q(<h1 class="rwtk_Headings">header 1</h1>\n<h2 class="rwtk_Headings">header 2</h2>\n<h3 class="rwtk_Headings">header 3</h3>\n<h4 class="rwtk_Headings">header 4</h4>\n<h5 class="rwtk_Headings">header 5</h5>\n<h6 class="rwtk_Headings">header 6</h6>\n<h6 class="rwtk_Headings">header 7->6</h6>\n== noheader 2\n)
    res     = %Q(<h1 class="rwtk_Headings">header 1</h1>\n<h2 class="rwtk_Headings">header 2</h2>\n<h3 class="rwtk_Headings">header 3</h3>\n<h4 class="rwtk_Headings">header 4</h4>\n<h5 class="rwtk_Headings">header 5</h5>\n<h6 class="rwtk_Headings">header 6</h6>\n<h6 class="rwtk_Headings">header 7->6</h6>\n<p class="rwtk_Paragraph">== noheader 2\n)

    __process(token, content, tkv, rpv, res)
  end

  def test_Blockquotes
    token   = Ruwiki::Wiki::Blockquotes
    content = ": level 1\n:: level 2\n::: level 3\n: level 1, para 2\n\\: not a blockquote\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\n\\TOKEN_4\n"
    rpv     = %Q(<blockquote class="rwtk_Blockquotes"> level 1</blockquote>\n<blockquote class="rwtk_Blockquotes"><blockquote class="rwtk_Blockquotes"> level 2</blockquote></blockquote>\n<blockquote class="rwtk_Blockquotes"><blockquote class="rwtk_Blockquotes"><blockquote class="rwtk_Blockquotes"> level 3</blockquote></blockquote></blockquote>\n<blockquote class="rwtk_Blockquotes"> level 1, para 2</blockquote>\n: not a blockquote\n)
    res     = %Q(<blockquote class="rwtk_Blockquotes">level 1<blockquote class="rwtk_Blockquotes">level 2<blockquote class="rwtk_Blockquotes">level 3</blockquote></blockquote>level 1, para 2</blockquote>\n: not a blockquote\n)
    __process(token, content, tkv, rpv, res)

    content = "> level 1\n>> level 2\n>>> level 3\n> level 1, para 2\n\\> not a blockquote\n"
    tkv     = "TOKEN_5\nTOKEN_6\nTOKEN_7\nTOKEN_8\n\\TOKEN_9\n"
    rpv     = %Q(<blockquote type="cite" class="rwtk_Blockquotes"> level 1</blockquote>\n<blockquote type="cite" class="rwtk_Blockquotes"><blockquote type="cite" class="rwtk_Blockquotes"> level 2</blockquote></blockquote>\n<blockquote type="cite" class="rwtk_Blockquotes"><blockquote type="cite" class="rwtk_Blockquotes"><blockquote type="cite" class="rwtk_Blockquotes"> level 3</blockquote></blockquote></blockquote>\n<blockquote type="cite" class="rwtk_Blockquotes"> level 1, para 2</blockquote>\n&gt; not a blockquote\n)
    res     = %Q(<blockquote type="cite" class="rwtk_Blockquotes">level 1<blockquote type="cite" class="rwtk_Blockquotes">level 2<blockquote type="cite" class="rwtk_Blockquotes">level 3</blockquote></blockquote>level 1, para 2</blockquote>\n&gt; not a blockquote\n)
    __process(token, content, tkv, rpv, res)
  end

  def test_Definitions
    token   = Ruwiki::Wiki::Definitions
    content = "; word1 : val1\n;; word2 : val2\n;;; word3 : val3\n; word1/2 : val1/2\n\\; not-a-word : not-a-val\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\n\\TOKEN_4\n"
    rpv     = %Q(<dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word1</dt><dd class="rwtk_Definitions">val1</dd></dl>\n<dl class="rwtk_Definitions"><dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word2</dt><dd class="rwtk_Definitions">val2</dd></dl></dl>\n<dl class="rwtk_Definitions"><dl class="rwtk_Definitions"><dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word3</dt><dd class="rwtk_Definitions">val3</dd></dl></dl></dl>\n<dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word1/2</dt><dd class="rwtk_Definitions">val1/2</dd></dl>\n; not-a-word : not-a-val\n)
    res     = %Q(<dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word1</dt><dd class="rwtk_Definitions">val1</dd><dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word2</dt><dd class="rwtk_Definitions">val2</dd><dl class="rwtk_Definitions"><dt class="rwtk_Definitions">word3</dt><dd class="rwtk_Definitions">val3</dd></dl></dl><dt class="rwtk_Definitions">word1/2</dt><dd class="rwtk_Definitions">val1/2</dd></dl>\n; not-a-word : not-a-val\n)

#   __display(token, content)
    __process(token, content, tkv, rpv, res)
  end

  def test_Lists
    token   = Ruwiki::Wiki::Lists
    content = "* level 1\n** level 2\n*** level 3\n*** level 3, item 2\n** level 2, item 2\n* level 1, item 2\n\\* not an item\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\nTOKEN_4\nTOKEN_5\n\\TOKEN_6\n"
    rpv     = %Q(<ul class="rwtk_Lists"><li class="rwtk_Lists">level 1</li></ul>\n<ul class="rwtk_Lists"><ul class="rwtk_Lists"><li class="rwtk_Lists">level 2</li></ul></ul>\n<ul class="rwtk_Lists"><ul class="rwtk_Lists"><ul class="rwtk_Lists"><li class="rwtk_Lists">level 3</li></ul></ul></ul>\n<ul class="rwtk_Lists"><ul class="rwtk_Lists"><ul class="rwtk_Lists"><li class="rwtk_Lists">level 3, item 2</li></ul></ul></ul>\n<ul class="rwtk_Lists"><ul class="rwtk_Lists"><li class="rwtk_Lists">level 2, item 2</li></ul></ul>\n<ul class="rwtk_Lists"><li class="rwtk_Lists">level 1, item 2</li></ul>\n* not an item\n)
    res     = %Q(<ul class="rwtk_Lists"><li class="rwtk_Lists">level 1</li><ul class="rwtk_Lists"><li class="rwtk_Lists">level 2</li><ul class="rwtk_Lists"><li class="rwtk_Lists">level 3</li><li class="rwtk_Lists">level 3, item 2</li></ul><li class="rwtk_Lists">level 2, item 2</li></ul><li class="rwtk_Lists">level 1, item 2</li></ul>\n* not an item\n)
    __process(token, content, tkv, rpv, res)

    content = "# level 1\n## level 2\n### level 3\n### level 3, item 2\n## level 2, item 2\n# level 1, item 2\n\\# not an item\n"
    tkv     = "TOKEN_7\nTOKEN_8\nTOKEN_9\nTOKEN_10\nTOKEN_11\nTOKEN_12\n\\TOKEN_13\n"
    rpv     = %Q(<ol class="rwtk_Lists"><li class="rwtk_Lists">level 1</li></ol>\n<ol class="rwtk_Lists"><ol class="rwtk_Lists"><li class="rwtk_Lists">level 2</li></ol></ol>\n<ol class="rwtk_Lists"><ol class="rwtk_Lists"><ol class="rwtk_Lists"><li class="rwtk_Lists">level 3</li></ol></ol></ol>\n<ol class="rwtk_Lists"><ol class="rwtk_Lists"><ol class="rwtk_Lists"><li class="rwtk_Lists">level 3, item 2</li></ol></ol></ol>\n<ol class="rwtk_Lists"><ol class="rwtk_Lists"><li class="rwtk_Lists">level 2, item 2</li></ol></ol>\n<ol class="rwtk_Lists"><li class="rwtk_Lists">level 1, item 2</li></ol>\n# not an item\n)
    res     = %Q(<ol class="rwtk_Lists"><li class="rwtk_Lists">level 1</li><ol class="rwtk_Lists"><li class="rwtk_Lists">level 2</li><ol class="rwtk_Lists"><li class="rwtk_Lists">level 3</li><li class="rwtk_Lists">level 3, item 2</li></ol><li class="rwtk_Lists">level 2, item 2</li></ol><li class="rwtk_Lists">level 1, item 2</li></ol>\n# not an item\n)
    __process(token, content, tkv, rpv, res)

    content = "# level 1\n*# level 2\n*** level 3\n*#* level 3, item 2\n## level 2, item 2\n# level 1, item 2\n\\# not an item\n"
    tkv     = "TOKEN_14\nTOKEN_15\nTOKEN_16\nTOKEN_17\nTOKEN_18\nTOKEN_19\n\\TOKEN_20\n"
    rpv     = %Q(<ol class="rwtk_Lists"><li class="rwtk_Lists">level 1</li></ol>\n<ul class="rwtk_Lists"><ol class="rwtk_Lists"><li class="rwtk_Lists">level 2</li></ol></ul>\n<ul class="rwtk_Lists"><ul class="rwtk_Lists"><ul class="rwtk_Lists"><li class="rwtk_Lists">level 3</li></ul></ul></ul>\n<ul class="rwtk_Lists"><ol class="rwtk_Lists"><ul class="rwtk_Lists"><li class="rwtk_Lists">level 3, item 2</li></ul></ol></ul>\n<ol class="rwtk_Lists"><ol class="rwtk_Lists"><li class="rwtk_Lists">level 2, item 2</li></ol></ol>\n<ol class="rwtk_Lists"><li class="rwtk_Lists">level 1, item 2</li></ol>\n# not an item\n)
    res     = %Q(<ol class="rwtk_Lists"><li class="rwtk_Lists">level 1</li><ol class="rwtk_Lists"><li class="rwtk_Lists">level 2</li><ul class="rwtk_Lists"><li class="rwtk_Lists">level 3</li><li class="rwtk_Lists">level 3, item 2</li></ul><li class="rwtk_Lists">level 2, item 2</li></ol><li class="rwtk_Lists">level 1, item 2</li></ol>\n# not an item\n)
    __process(token, content, tkv, rpv, res)
  end


  def test_RubyTalkLinks
    token   = Ruwiki::Wiki::RubyTalkLinks
    content = "[ruby-talk:12345] \\[ruby-talk:12345]"
    tkv     = "TOKEN_0 \\TOKEN_1"
#   rpv     = %Q(<a class="rwtk_RubyTalkLinks" href="http://www.ruby-talk.org/12345">[ruby-talk:12345]</a> [ruby-talk:12345])
    rpv     = %Q(<a class="rwtk_RubyTalkLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/12345">[ruby-talk:12345]</a> [ruby-talk:12345])
#   res     = %Q(<a class="rwtk_RubyTalkLinks" href="http://www.ruby-talk.org/12345">[ruby-talk:12345]</a> [ruby-talk:12345])
    res     = %Q(<a class="rwtk_RubyTalkLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/12345">[ruby-talk:12345]</a> [ruby-talk:12345])

    __process(token, content, tkv, rpv, res)
  end

  def test_OtherRubyLinks
    token   = Ruwiki::Wiki::OtherRubyLinks
    content = "[ruby-list:123] \\[ruby-list:123] [ruby-doc:123] \\[ruby-doc:123] [ruby-core:123] \\[ruby-core:123] [ruby-dev:123] \\[ruby-dev:123] [ruby-ext:123] \\[ruby-ext:123] [ruby-math:123] \\[ruby-math:123]"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 TOKEN_4 \\TOKEN_5 TOKEN_6 \\TOKEN_7 TOKEN_8 \\TOKEN_9 TOKEN_10 \\TOKEN_11"
    rpv     = %Q(<a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/123">[ruby-list:123]</a> [ruby-list:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-doc/123">[ruby-doc:123]</a> [ruby-doc:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/123">[ruby-core:123]</a> [ruby-core:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/123">[ruby-dev:123]</a> [ruby-dev:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-ext/123">[ruby-ext:123]</a> [ruby-ext:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-math/123">[ruby-math:123]</a> [ruby-math:123])
    res     = %Q(<a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/123">[ruby-list:123]</a> [ruby-list:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-doc/123">[ruby-doc:123]</a> [ruby-doc:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/123">[ruby-core:123]</a> [ruby-core:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/123">[ruby-dev:123]</a> [ruby-dev:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-ext/123">[ruby-ext:123]</a> [ruby-ext:123] <a class="rwtk_OtherRubyLinks" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-math/123">[ruby-math:123]</a> [ruby-math:123])

    __process(token, content, tkv, rpv, res)
  end
end
