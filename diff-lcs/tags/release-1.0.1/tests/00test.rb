#! /usr/bin/env ruby
#
$:.unshift '../lib' if __FILE__ == $0 # Make this library first!

require 'diff/lcs'
require 'test/unit'
require 'pp'
require 'diff/lcs/array'

if __FILE__ == $0
  class TestLCS < Test::Unit::TestCase
    def setup
      @a = %w(a b c e h j l m n p)
      @b = %w(b c d e f j k l m r s t)

      @correct = %w(b c e j l m)
      @skipped_a = "a h n p"
      @skipped_b = "d f k r s t"

      correct_diff = [
        [ [ '-', 0, 'a' ] ],
        [ [ '+', 2, 'd' ] ],
        [ [ '-', 4, 'h' ],
          [ '+', 4, 'f' ] ],
        [ [ '+', 6, 'k' ] ],
        [ [ '-', 8,  'n' ],
          [ '+', 9,  'r' ],
          [ '-', 9,  'p' ],
          [ '+', 10, 's' ],
          [ '+', 11, 't' ] ] ]
      @correct_diff = __map_diffs(correct_diff)
    end

    def __map_diffs(diffs)
      diffs.map do |chunks|
        chunks.map do |changes|
          Diff::LCS::Change.from_a(*changes)
        end
      end
    end

    def __make_callbacks
      callbacks = Object.new
      class << callbacks
        attr_reader :matched_a
        attr_reader :matched_b
        attr_reader :discards_a
        attr_reader :discards_b
        attr_reader :done_a
        attr_reader :done_b

        def reset
          @matched_a = []
          @matched_b = []
          @discards_a = []
          @discards_b = []
          @done_a = []
          @done_b = []
        end

        def match(event)
          @matched_a << event.old_el
          @matched_b << event.new_el
        end

        def discard_b(event)
          @discards_b << event.new_el
        end

        def discard_a(event)
          @discards_a << event.old_el
        end

        def finished_a(event)
          @done_a << [event.old_el, event.old_ix]
        end

        def finished_b(event)
          @done_b << [event.new_el, event.new_ix]
        end
      end
      callbacks.reset
      callbacks
    end

    def test_lcs
      res = ares = bres = nil
      assert_nothing_raised { res = Diff::LCS.__lcs(@a, @b) }
        # The result of the LCS (less the +nil+ values) must be as long as the
        # correct result.
      assert_equal(res.compact.size, @correct.size)
      assert_nothing_raised { ares = (0...res.size).map { |i| res[i] ? @a[i] : nil } }
      assert_nothing_raised { bres = (0...res.size).map { |i| res[i] ? @b[res[i]] : nil } }
      assert_equal(@correct, ares.compact)
      assert_equal(@correct, bres.compact)
    end

    def test_sequences
      callbacks = nil
      assert_nothing_raised do
        callbacks = __make_callbacks
        class << callbacks
          undef finished_a
          undef finished_b
        end
      end
      assert_nothing_raised { Diff::LCS.traverse_sequences(@a, @b, callbacks) }
      assert_equal(@correct.size, callbacks.matched_a.size)
      assert_equal(@correct.size, callbacks.matched_b.size)
      assert_equal(@skipped_a, callbacks.discards_a.join(" "))
      assert_equal(@skipped_b, callbacks.discards_b.join(" "))
      assert_nothing_raised { callbacks = __make_callbacks }
      assert_nothing_raised { Diff::LCS.traverse_sequences(@a, @b, callbacks) }
      assert_equal(@correct.size, callbacks.matched_a.size)
      assert_equal(@correct.size, callbacks.matched_b.size)
      assert_equal(@skipped_a, callbacks.discards_a.join(" "))
      assert_equal(@skipped_b, callbacks.discards_b.join(" "))
      assert_equal(9, callbacks.done_a[0][1])
      assert_nil(callbacks.done_b[0])
    end

    def test_LCS
      res = nil
      assert_nothing_raised { res = Diff::LCS.LCS(@a, @b) }
      assert_equal(res.compact, @correct)
    end

    def test_diff
      diff = nil
      assert_nothing_raised { diff = Diff::LCS.diff(@a, @b) }
      assert_equal(@correct_diff, diff)
    end

    def test_sdiff_a
      sdiff = nil
      a = %w(abc def yyy xxx ghi jkl)
      b = %w(abc dxf xxx ghi jkl)
      correct_sdiff = [
        ['u', 'abc', 'abc'],
        ['!', 'def', 'dxf'],
        ['-', 'yyy', nil],
        ['u', 'xxx', 'xxx'],
        ['u', 'ghi', 'ghi'],
        ['u', 'jkl', 'jkl'] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_b
      sdiff = nil
      correct_sdiff = [
        ['-', 'a', nil],
        ['u', 'b', 'b'],
        ['u', 'c', 'c'],
        ['+', nil, 'd'],
        ['u', 'e', 'e'],
        ['!', 'h', 'f'],
        ['u', 'j', 'j'],
        ['+', nil, 'k'],
        ['u', 'l', 'l'],
        ['u', 'm', 'm'],
        ['!', 'n', 'r'],
        ['!', 'p', 's'],
        ['+', nil, 't'] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(@a, @b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_c
      sdiff = nil
      a = %w(a b c d e)
      b = %w(a e)
      correct_sdiff = [
        ['u', 'a', 'a' ],
        ['-', 'b', nil ],
        ['-', 'c', nil ],
        ['-', 'd', nil ],
        ['u', 'e', 'e' ] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_d
      sdiff = nil
      a = %w(a e)
      b = %w(a b c d e)
      correct_sdiff = [
        ['u', 'a', 'a' ],
        ['+', nil, 'b' ],
        ['+', nil, 'c' ],
        ['+', nil, 'd' ],
        ['u', 'e', 'e' ] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_e
      sdiff = nil
      a = %w(v x a e)
      b = %w(w y a b c d e)
      correct_sdiff = [
        ['!', 'v', 'w' ],
        ['!', 'x', 'y' ],
        ['u', 'a', 'a' ],
        ['+', nil, 'b'],
        ['+', nil, 'c'],
        ['+', nil, 'd'],
        ['u', 'e', 'e'] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_f
      sdiff = nil
      a = %w(x a e)
      b = %w(a b c d e)
      correct_sdiff = [
        ['-', 'x', nil ],
        ['u', 'a', 'a' ],
        ['+', nil, 'b'],
        ['+', nil, 'c'],
        ['+', nil, 'd'],
        ['u', 'e', 'e'] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_g
      sdiff = nil
      a = %w(a e)
      b = %w(x a b c d e)
      correct_sdiff = [
        ['+', nil, 'x' ],
        ['u', 'a', 'a' ],
        ['+', nil, 'b'],
        ['+', nil, 'c'],
        ['+', nil, 'd'],
        ['u', 'e', 'e'] ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_h
      sdiff = nil
      a = %w(a e v)
      b = %w(x a b c d e w x)
      correct_sdiff = [
        ['+', nil, 'x' ],
        ['u', 'a', 'a' ],
        ['+', nil, 'b'],
        ['+', nil, 'c'],
        ['+', nil, 'd'],
        ['u', 'e', 'e'],
        ['!', 'v', 'w'],
        ['+', nil,  'x']
      ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_i
      sdiff = nil
      a = %w()
      b = %w(a b c)
      correct_sdiff = [
        ['+', nil, 'a' ],
        ['+', nil, 'b' ],
        ['+', nil, 'c' ]
      ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_j
      sdiff = nil
      a = %w(a b c)
      b = %w()
      correct_sdiff = [
        ['-', 'a', nil ],
        ['-', 'b', nil ],
        ['-', 'c', nil ]
      ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_k
      sdiff = nil
      a = %w(a b c)
      b = %w(1)
      correct_sdiff = [
        ['!', 'a', '1' ],
        ['-', 'b', nil ],
        ['-', 'c', nil ]
      ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def test_sdiff_l
      sdiff = nil
      a = %w(a b c)
      b = %w(c)
      correct_sdiff = [
        ['-', 'a', nil ],
        ['-', 'b', nil ],
        ['u', 'c', 'c' ]
      ]
      correct_sdiff = __map_diffs([correct_sdiff])[0]
      assert_nothing_raised { sdiff = Diff::LCS.sdiff(a, b) }
      assert_equal(correct_sdiff, sdiff)
    end

    def __balanced_callback
      cb = Object.new
      class << cb
        attr_reader :result

        def reset
          @result = ""
        end

        def match(event)
          @result << "M #{event.old_ix} #{event.new_ix}"
        end

        def discard_a(event)
          @result << "DA #{event.old_ix} #{event.new_ix}"
        end

        def discard_b(event)
          @result << "DB #{event.old_ix} #{event.new_ix}"
        end

        def change(event)
          @result << "C #{event.old_ix} #{event.new_ix}"
        end
      end
      cb.reset
      cb
    end

    def test_balanced_a
      a = %w(a b c)
      b = %w(a x c)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("M 0 0C 1 1M 2 2", callback.result)
    end

    def test_balanced_b
      a = %w(a b c)
      b = %w(a x c)
      callback = nil
      assert_nothing_raised do
        callback = __balanced_callback
        class << callback
          undef change
        end
      end
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("M 0 0DA 1 1DB 2 1M 2 2", callback.result)
    end

    def test_balanced_c
      a = %w(a x y c)
      b = %w(a v w c)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("M 0 0C 1 1C 2 2M 3 3", callback.result)
    end

    def test_balanced_d
      a = %w(x y c)
      b = %w(v w c)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("C 0 0C 1 1M 2 2", callback.result)
    end

    def test_balanced_e
      a = %w(a x y z)
      b = %w(b v w)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("C 0 0C 1 1C 2 2DA 3 3", callback.result)
    end

    def test_balanced_f
      a = %w(a z)
      b = %w(a)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("M 0 0DA 1 1", callback.result)
    end

    def test_balanced_g
      a = %w(z a)
      b = %w(a)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("DA 0 0M 1 0", callback.result)
    end

    def test_balanced_h
      a = %w(a b c)
      b = %w(x y z)
      callback = nil
      assert_nothing_raised { callback = __balanced_callback }
      assert_nothing_raised { Diff::LCS.traverse_balanced(a, b, callback) }
      assert_equal("C 0 0C 1 1C 2 2", callback.result)
    end
  end
end
