#!/usr/bin/env ruby
#--
# Ruwiki version 0.8.0
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
require 'test/unit'
require 'harness-cgi'

  class TestTemplates < Test::Unit::TestCase
    def test_include
      a = "a!INCLUDE!c"
      b = "b"
      t = Ruwiki::TemplatePage.new(a, b)
      assert_equal(["abc"], t.lines.lines)
    end

    def test_variables
      a = "a%b%c"
      v = { "b" => "b" }
      t = Ruwiki::TemplatePage.new(a)
      assert_equal("abc", t.process("", v))
    end

    def test_optional_variables
      a = "a%b%%?c%d"
      v = { "b" => "b" }
      t = Ruwiki::TemplatePage.new(a)
      assert_equal("abd", t.process("", v))

      v["c"] = "c"
      assert_equal("abcd", t.process("", v))
    end

    def test_labels
      a = "a#b#c"
      v = {}
      m = { "b" => "b" }
      t = Ruwiki::TemplatePage.new(a)
      assert_equal("abc", t.process("", v, m))
    end

    def test_optional_labels
      a = "a#b##?c#d"
      v = {}
      m = { "b" => "b" }
      t = Ruwiki::TemplatePage.new(a)
      assert_equal("abd", t.process("", v, m))

      m["c"] = "c"
      assert_equal("abcd", t.process("", v, m))
    end

    def test_hrefs
      a = "HREF:a:b:"
      t = Ruwiki::TemplatePage.new(a)
      v = { "b" => "b" }

      assert_equal("b", t.process("", v))

      s = ""
      v["a"] = "link"
      assert_equal(%Q(<a href="link">b</a>), t.process("", v))
    end

    def test_repeat_subst
      v1 = { "a" => 3 }
      v2 = { "a" => 2...4 }
      v3 = { "a" => -4...-2 }
      v4 = { "a" => [3, 1, 4, 1, 5, 9] }
      v5 = { "a" => [{ "a" => 3 }, { "a" => 1 }, { "a" => 4 }, { "a" => 1 }, { "a" => 5 }, { "a" => 9 }] }

      a = "[:a|xy:]"
      t = Ruwiki::TemplatePage.new(a)
      assert_equal("xyxyxy", t.process("", v1))
      assert_equal("xyxy", t.process("", v2))
      assert_equal("xyxy", t.process("", v3))
      assert_equal("xyxyxyxyxyxy", t.process("", v4))
      assert_equal("xyxyxyxyxyxy", t.process("", v5))

      a = "[:a|%a%:]"
      t = Ruwiki::TemplatePage.new(a)
      assert_equal("123", t.process("", v1))
      assert_equal("23", t.process("", v2))
      assert_equal("-4-3", t.process("", v3))
      assert_equal("314159", t.process("", v4))
      assert_equal("314159", t.process("", v5))
    end

    def test_optional_subst
      v1 = { "a" => "a" }
      v2 = { "a" => nil }
      a1 = "[?a|xy?]"
      a2 = "[!a|xy?]"
      t1 = Ruwiki::TemplatePage.new(a1)
      t2 = Ruwiki::TemplatePage.new(a2)

      assert_equal("xy", t1.process("", v1))
      assert_equal("", t1.process("", v2))
      assert_equal("", t2.process("", v1))
      assert_equal("xy", t2.process("", v2))
    end

    def test_repeat_block
      a1 = "START:a\nxy\nEND:a"
      a2 = "START:a\nx%b%y\nEND:a"
      a3 = "START:\nEND:"
      t1 = Ruwiki::TemplatePage.new(a1)
      t2 = Ruwiki::TemplatePage.new(a2)
      t3 = Ruwiki::TemplatePage.new(a3)
      v = { "a" => [{ "b" => 3 }, { "b" => 1 }, { "b" => 4 }, { "b" => 1 }, { "b" => 5 }, { "b" => 9 }] }

      assert_equal("xy\nxy\nxy\nxy\nxy\nxy\n", t1.process("", v))
      assert_equal("x3y\nx1y\nx4y\nx1y\nx5y\nx9y\n", t2.process("", v))
      assert_raises(RuntimeError) { t3.process("", v) }
    end

    def test_optional_block
      a1 = "IF:a\nxy\nENDIF:a"
      a2 = "IF:\nxy\nEND:"
      a3 = "IFNOT:a\nxy\nENDIF:a"
      a4 = "IFNOT:\nxy\nEND:"
      t1 = Ruwiki::TemplatePage.new(a1)
      t2 = Ruwiki::TemplatePage.new(a2)
      t3 = Ruwiki::TemplatePage.new(a3)
      t4 = Ruwiki::TemplatePage.new(a4)
      v1 = { "a" => true }
      v2 = { "a" => nil }

      assert_equal("xy", t1.process("", v1))
      assert_equal("", t1.process("", v2))
      assert_raises(RuntimeError) { t2.process("", v1) }
      assert_equal("", t3.process("", v1))
      assert_equal("xy", t3.process("", v2))
      assert_raises(RuntimeError) { t4.process("", v1) }
    end
  end
