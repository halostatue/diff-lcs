#!/usr/bin/env ruby
#--
# Ruwiki version 0.6.1
#   Copyright © 2002 - 2003, Digikata and HaloStatue
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
require 'harness-cgi'

class TokenTestCases < Test::Unit::TestCase
  def setup
    @project  = "Default"
    @tokens   = []
  end

  def __tokenize(content, token)
    content.gsub!(token.regexp) do |m|
      match = Regexp.last_match
      tc    = token.new(match, @project, $wiki.backend, $wiki.request.script_url)
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
    3.times do
      @tokens.reverse_each { |token| token.post_replace(content) }
    end
    content
  end

  def __process(token, content, tokenized, replaced, result)
    assert_equal(tokenized, content = __tokenize(content, token))
    assert_equal(replaced, content = __replace(content))
    assert_equal(result, content = __post_replace(content))
  end

  def __display(token, content)
    p tokenized = __tokenize(content.dup, token)
    p replaced  = __replace(tokenized.dup)
    p result    = __post_replace(replaced.dup)
  end

  def test_Paragraph
    token   = Ruwiki::Wiki::Paragraph
    content = "\nABC\n\nabc\n"
    tkv     = "TOKEN_0\nABC\nTOKEN_1\nabc\n"
    rpv     = "<p>\nABC\n<p>\nabc\n"
    res     = "<p>ABC</p><p>abc</p>"

    __process(token, content, tkv, rpv, res)
  end

  def test_Code
    content = "  line 1\n    line 2\nline3\n"
    token   = Ruwiki::Wiki::Code
    tkv     = "TOKEN_0\nTOKEN_1\nline3\n"
    rpv     = "<pre>  line 1</pre>\n<pre>    line 2</pre>\nline3\n"
    res     = "<pre>  line 1\n    line 2</pre>\nline3\n"

    __process(token, content, tkv, rpv, res)
  end

  def test_NumberedLinks
    token   = Ruwiki::Wiki::NumberedLinks
    content = "[http://www.ruby-lang.org] \\[http://www.rubyforge.org]"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = %Q{<a class="rw_extlink" href="http://www.ruby-lang.org">[1]</a> [http://www.rubyforge.org]}
    res     = %Q{<a class="rw_extlink" href="http://www.ruby-lang.org">[1]</a> [http://www.rubyforge.org]}

    __process(token, content, tkv, rpv, res)
  end

  def test_NamedLinks
    token   = Ruwiki::Wiki::NamedLinks
    content = "[http://www.ruby-lang.org Ruby] \\[http://www.rubyforge.org RubyForge]"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = %Q{<a class="rw_extlink" href="http://www.ruby-lang.org">Ruby</a> [http://www.rubyforge.org RubyForge]}
    res     = %Q{<a class="rw_extlink" href="http://www.ruby-lang.org">Ruby</a> [http://www.rubyforge.org RubyForge]}

    __process(token, content, tkv, rpv, res)
  end

  def test_ExternalLinks
    token   = Ruwiki::Wiki::ExternalLinks
    content = "http://www.ruby-lang.org \\http://www.rubyforge.org"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = %Q{<a class="rw_extlink" href="http://www.ruby-lang.org">http://www.ruby-lang.org</a> http://www.rubyforge.org}
    res     = %Q{<a class="rw_extlink" href="http://www.ruby-lang.org">http://www.ruby-lang.org</a> http://www.rubyforge.org}

    __process(token, content, tkv, rpv, res)
  end

  def test_HRule
    token   = Ruwiki::Wiki::HRule
    content = "----\n\\----"
    tkv     = "TOKEN_0\n\\TOKEN_1"
    rpv     = "<hr />\n----"
    res     = "<hr />\n----"

    __process(token, content, tkv, rpv, res)
  end

  def test_ProjectCrossLink
    token   = Ruwiki::Wiki::ProjectCrossLink
    content = "Ruwiki::ChangeLog \\Ruwiki::To_Do Ruwiki::NotExist \\Ruwiki::NotExist"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3"
    rpv     = %Q{<a class="rw_pagelink" href="http://:/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::To_Do <span class="rw_edittext">Ruwiki::NotExist</span><a class="rw_pagelink" href="http://:/Ruwiki/NotExist/_edit">?</a> Ruwiki::NotExist}
    res     = %Q{<a class="rw_pagelink" href="http://:/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::To_Do <span class="rw_edittext">Ruwiki::NotExist</span><a class="rw_pagelink" href="http://:/Ruwiki/NotExist/_edit">?</a> Ruwiki::NotExist}

    __process(token, content, tkv, rpv, res)
  end

  def test_ProjectCrossLinkWikipedia
    token   = Ruwiki::Wiki::ProjectCrossLinkWikipedia
    content = "Ruwiki::[[ChangeLog]] \\Ruwiki::[[To_Do]] Ruwiki::[[Does Not Exist]] \\Ruwiki::[[Does Not Exist]] Ruwiki::[[_invalid]]"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 Ruwiki::[[_invalid]]"
    rpv     = %Q{<a class="rw_pagelink" href="http://:/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::[[To_Do]] <span class="rw_edittext">Ruwiki::Does Not Exist</span><a class="rw_pagelink" href="http://:/Ruwiki/Does+Not+Exist/_edit">?</a> Ruwiki::[[Does Not Exist]] Ruwiki::[[_invalid]]}
    res     = %Q{<a class="rw_pagelink" href="http://:/Ruwiki/ChangeLog">Ruwiki::ChangeLog</a> Ruwiki::[[To_Do]] <span class="rw_edittext">Ruwiki::Does Not Exist</span><a class="rw_pagelink" href="http://:/Ruwiki/Does+Not+Exist/_edit">?</a> Ruwiki::[[Does Not Exist]] Ruwiki::[[_invalid]]}

    __process(token, content, tkv, rpv, res)
  end

  def test_ProjectIndex
    token   = Ruwiki::Wiki::ProjectIndex
    content = "::Ruwiki \\::Ruwiki ::Newproject \\::Newproject"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3"
    rpv     = %Q{<a class="rw_pagelink" href="http://:/Ruwiki/ProjectIndex">Ruwiki</a> ::Ruwiki <span class="rw_edittext">Newproject</span><a class="rw_pagelink" href="http://:/Newproject/_create">?</a> ::Newproject}
    res     = %Q{<a class="rw_pagelink" href="http://:/Ruwiki/ProjectIndex">Ruwiki</a> ::Ruwiki <span class="rw_edittext">Newproject</span><a class="rw_pagelink" href="http://:/Newproject/_create">?</a> ::Newproject}

    __process(token, content, tkv, rpv, res)
  end

  def test_WikiLinks
    token   = Ruwiki::Wiki::WikiLinks
    content = "ProjectIndex \\ProjectIndex AustinZiegler \\AustinZiegler Alan_Chen \\Alan_Chen"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 TOKEN_4 \\TOKEN_5"
    rpv     = %Q{<a class="rw_pagelink" href="http://:/Default/ProjectIndex">ProjectIndex</a> ProjectIndex <span class="rw_edittext">AustinZiegler</span><a class="rw_pagelink" href="http://:/Default/AustinZiegler/_edit">?</a> AustinZiegler <span class="rw_edittext">Alan Chen</span><a class="rw_pagelink" href="http://:/Default/Alan_Chen/_edit">?</a> Alan_Chen}
    res     = %Q{<a class="rw_pagelink" href="http://:/Default/ProjectIndex">ProjectIndex</a> ProjectIndex <span class="rw_edittext">AustinZiegler</span><a class="rw_pagelink" href="http://:/Default/AustinZiegler/_edit">?</a> AustinZiegler <span class="rw_edittext">Alan Chen</span><a class="rw_pagelink" href="http://:/Default/Alan_Chen/_edit">?</a> Alan_Chen}

    __process(token, content, tkv, rpv, res)
  end

  def test_WikipediaLinks
    token   = Ruwiki::Wiki::WikipediaLinks
    content = "[[ProjectIndex]] \\[[ProjectIndex]] [[Austin Ziegler]] \\[[Austin Ziegler]] [[_Alan Chen]]"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 [[_Alan Chen]]"
    rpv     = %Q{<a class=\"rw_pagelink\" href=\"http://:/Default/ProjectIndex\">ProjectIndex</a> [[ProjectIndex]] <span class=\"rw_edittext\">Austin Ziegler</span><a class=\"rw_pagelink\" href=\"http://:/Default/Austin+Ziegler/_edit\">?</a> [[Austin Ziegler]] [[_Alan Chen]]}
    res     = %Q{<a class=\"rw_pagelink\" href=\"http://:/Default/ProjectIndex\">ProjectIndex</a> [[ProjectIndex]] <span class=\"rw_edittext\">Austin Ziegler</span><a class=\"rw_pagelink\" href=\"http://:/Default/Austin+Ziegler/_edit\">?</a> [[Austin Ziegler]] [[_Alan Chen]]}

    __process(token, content, tkv, rpv, res)
  end

  def test_Abbreviations
    token   = Ruwiki::Wiki::Abbreviations
    content = "@{PM}\n@{}\n\\@{PM}"
    tkv     = "TOKEN_0\nTOKEN_1\n\\TOKEN_2"
    rpv     = "PocoMail\n<dl><dt>PM</dt><dd>PocoMail</dd></dl>\n@{PM}"
    res     = "PocoMail\n<dl><dt>PM</dt><dd>PocoMail</dd></dl>\n@{PM}"

    __process(token, content, tkv, rpv, res)
  end

  def test_Headings
    token   = Ruwiki::Wiki::Headings
    content = "= header 1\n== header 2\n=== header 3\n==== header 4\n===== header 5\n====== header 6\n======= header 7->6\n\\== noheader 2\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\nTOKEN_4\nTOKEN_5\nTOKEN_6\n\\TOKEN_7\n"
    rpv     = "<h1>header 1</h1>\n<h2>header 2</h2>\n<h3>header 3</h3>\n<h4>header 4</h4>\n<h5>header 5</h5>\n<h6>header 6</h6>\n<h6>header 7->6</h6>\n== noheader 2\n"
    res     = "<h1>header 1</h1>\n<h2>header 2</h2>\n<h3>header 3</h3>\n<h4>header 4</h4>\n<h5>header 5</h5>\n<h6>header 6</h6>\n<h6>header 7->6</h6>\n== noheader 2\n"

    __process(token, content, tkv, rpv, res)
  end

  def test_Lists
    token   = Ruwiki::Wiki::Lists
    content =  "* level 1\n** level 2\n*** level 3\n* level 1, item 2\n\\* not an item\n"
    content << "# level 1\n## level 2\n### level 3\n# level 1, item 2\n\\# not an item\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\n\\TOKEN_4\nTOKEN_5\nTOKEN_6\nTOKEN_7\nTOKEN_8\n\\TOKEN_9\n"
    rpv     = "<ul><li>level 1</li></ul>\n<ul><li><ul><li>level 2</li></ul></li></ul>\n<ul><li><ul><li><ul><li>level 3</li></ul></li></ul></li></ul>\n<ul><li>level 1, item 2</li></ul>\n* not an item\n<ol><li>level 1</li></ol>\n<ol><li><ol><li>level 2</li></ol></li></ol>\n<ol><li><ol><li><ol><li>level 3</li></ol></li></ol></li></ol>\n<ol><li>level 1, item 2</li></ol>\n# not an item\n"
    res     = "<ul><li>level 1</li><ul><li>level 2</li><ul><li>level 3</li></ul></ul><li>level 1, item 2</li></ul>\n* not an item\n<ol><li>level 1</li><ol><li>level 2</li><ol><li>level 3</li></ol></ol><li>level 1, item 2</li></ol>\n# not an item\n"

    __process(token, content, tkv, rpv, res)
  end

  def test_Blockquotes
    token   = Ruwiki::Wiki::Blockquotes
    content = ": level 1\n:: level 2\n::: level 3\n: level 1, para 2\n\\: not a blockquote\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\n\\TOKEN_4\n"
    rpv     = "<blockquote>level 1</blockquote>\n<blockquote><blockquote>level 2</blockquote></blockquote>\n<blockquote><blockquote><blockquote>level 3</blockquote></blockquote></blockquote>\n<blockquote>level 1, para 2</blockquote>\n: not a blockquote\n"
    res     = "<blockquote>level 1<blockquote>level 2<blockquote>level 3</blockquote></blockquote>level 1, para 2</blockquote>\n: not a blockquote\n"

    __process(token, content, tkv, rpv, res)
  end

  def test_Lists
    token   = Ruwiki::Wiki::Definitions
    content = "; word1 : val1\n;; word2 : val2\n;;; word3 : val3\n; word1/2 : val1/2\n\\; not-a-word : not-a-val\n"
    tkv     = "TOKEN_0\nTOKEN_1\nTOKEN_2\nTOKEN_3\n\\TOKEN_4\n"
    rpv     = "<dl><dt>word1</dt><dd>val1</dd></dl>\n<dl><dl><dt>word2</dt><dd>val2</dd></dl></dl>\n<dl><dl><dl><dt>word3</dt><dd>val3</dd></dl></dl></dl>\n<dl><dt>word1/2</dt><dd>val1/2</dd></dl>\n; not-a-word : not-a-val\n"
    res     = "<dl><dt>word1</dt><dd>val1</dd><dl><dt>word2</dt><dd>val2</dd><dl><dt>word3</dt><dd>val3</dd></dl></dl><dt>word1/2</dt><dd>val1/2</dd></dl>\n; not-a-word : not-a-val\n"

    __process(token, content, tkv, rpv, res)
  end

  def test_RubyTalkLinks
    token   = Ruwiki::Wiki::RubyTalkLinks
    content = "[ruby-talk:12345] \\[ruby-talk:12345]"
    tkv     = "TOKEN_0 \\TOKEN_1"
    rpv     = "<a class=\"rw_extlink\" href=\"http://www.ruby-talk.org/12345\">[ruby-talk:12345]</a> [ruby-talk:12345]"
    res     = "<a class=\"rw_extlink\" href=\"http://www.ruby-talk.org/12345\">[ruby-talk:12345]</a> [ruby-talk:12345]"

    __process(token, content, tkv, rpv, res)
  end

  def test_OtherRubyLinks
    token   = Ruwiki::Wiki::OtherRubyLinks
    content = "[ruby-list:123] \\[ruby-list:123] [ruby-doc:123] \\[ruby-doc:123] [ruby-core:123] \\[ruby-core:123] [ruby-dev:123] \\[ruby-dev:123] [ruby-ext:123] \\[ruby-ext:123] [ruby-math:123] \\[ruby-math:123]"
    tkv     = "TOKEN_0 \\TOKEN_1 TOKEN_2 \\TOKEN_3 TOKEN_4 \\TOKEN_5 TOKEN_6 \\TOKEN_7 TOKEN_8 \\TOKEN_9 TOKEN_10 \\TOKEN_11"
    rpv     = "<a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/123\">[ruby-list:123]</a> [ruby-list:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-doc/123\">[ruby-doc:123]</a> [ruby-doc:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/123\">[ruby-core:123]</a> [ruby-core:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/123\">[ruby-dev:123]</a> [ruby-dev:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-ext/123\">[ruby-ext:123]</a> [ruby-ext:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-math/123\">[ruby-math:123]</a> [ruby-math:123]"
    res     = "<a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/123\">[ruby-list:123]</a> [ruby-list:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-doc/123\">[ruby-doc:123]</a> [ruby-doc:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/123\">[ruby-core:123]</a> [ruby-core:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/123\">[ruby-dev:123]</a> [ruby-dev:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-ext/123\">[ruby-ext:123]</a> [ruby-ext:123] <a class=\"rw_extlink\" href=\"http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-math/123\">[ruby-math:123]</a> [ruby-math:123]"

    __process(token, content, tkv, rpv, res)
  end
end
