#! /usr/bin/env ruby
#
$:.unshift '../lib' if __FILE__ == $0 # Make this library first!

require 'diff/lcs'
require 'test/unit'
require 'pp'
require 'diff/lcs/array'

class TestDiffLCSBaseMethods < Test::Unit::TestCase
  def __format_diffs(diffs)
    diffs.map do |e|
      if e.kind_of?(Array)
        e.map { |f| f.to_a.join }.join(", ")
      else
        e.to_a.join
      end
    end.join("; ")
  end

  def __map_diffs(diffs, klass = Diff::LCS::ContextChange)
    diffs.map do |chunks|
      if klass == Diff::LCS::ContextChange
        klass.from_a(chunks)
      else
        chunks.map { |changes| klass.from_a(changes) }
      end
    end
  end

  def __simple_callbacks
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
        @matched_a << event.old_element
        @matched_b << event.new_element
      end

      def discard_b(event)
        @discards_b << event.new_element
      end

      def discard_a(event)
        @discards_a << event.old_element
      end

      def finished_a(event)
        @done_a << [event.old_element, event.old_position]
      end

      def finished_b(event)
        @done_b << [event.new_element, event.new_position]
      end
    end
    callbacks.reset
    callbacks
  end

  def __balanced_callback
    cb = Object.new
    class << cb
      attr_reader :result

      def reset
        @result = ""
      end

      def match(event)
        @result << "M#{event.old_position}#{event.new_position} "
      end

      def discard_a(event)
        @result << "DA#{event.old_position}#{event.new_position} "
      end

      def discard_b(event)
        @result << "DB#{event.old_position}#{event.new_position} "
      end

      def change(event)
        @result << "C#{event.old_position}#{event.new_position} "
      end
    end
    cb.reset
    cb
  end

  def setup
    @seq1 = %w(a b c e h j l m n p)
    @seq2 = %w(b c d e f j k l m r s t)

    @correct_lcs = %w(b c e j l m)

    @skipped_seq1 = 'a h n p'
    @skipped_seq2 = 'd f k r s t'

    correct_diff = [
      [ [ '-',  0, 'a' ] ],
      [ [ '+',  2, 'd' ] ],
      [ [ '-',  4, 'h' ],
        [ '+',  4, 'f' ] ],
      [ [ '+',  6, 'k' ] ],
      [ [ '-',  8, 'n' ],
        [ '+',  9, 'r' ],
        [ '-',  9, 'p' ],
        [ '+', 10, 's' ],
        [ '+', 11, 't' ] ] ]
    @correct_diff = __map_diffs(correct_diff, Diff::LCS::Change)
  end

  def test_lcs
    res = ares = bres = nil
    assert_nothing_raised { res = Diff::LCS.__lcs(@seq1, @seq2) }
      # The result of the LCS (less the +nil+ values) must be as long as the
      # correct result.
    assert_equal(res.compact.size, @correct_lcs.size)
    res.each_with_index { |ee, ii| assert(ee.nil? || (@seq1[ii] == @seq2[ee])) }
    assert_nothing_raised { ares = (0...res.size).map { |ii| res[ii] ? @seq1[ii] : nil } }
    assert_nothing_raised { bres = (0...res.size).map { |ii| res[ii] ? @seq2[res[ii]] : nil } }
    assert_equal(@correct_lcs, ares.compact)
    assert_equal(@correct_lcs, bres.compact)
    assert_nothing_raised { res = Diff::LCS.LCS(@seq1, @seq2) }
    assert_equal(res.compact, @correct_lcs)
  end
end

class TestSequences < TestDiffLCSBaseMethods
  def test_sequences
    callbacks = nil
    assert_nothing_raised do
      callbacks = __simple_callbacks
      class << callbacks
        undef :finished_a
        undef :finished_b
      end
    end
    assert_nothing_raised { Diff::LCS.traverse_sequences(@seq1, @seq2, callbacks) }
    assert_equal(@correct_lcs.size, callbacks.matched_a.size)
    assert_equal(@correct_lcs.size, callbacks.matched_b.size)
    assert_equal(@skipped_seq1, callbacks.discards_a.join(" "))
    assert_equal(@skipped_seq2, callbacks.discards_b.join(" "))
    assert_nothing_raised { callbacks = __simple_callbacks }
    assert_nothing_raised { Diff::LCS.traverse_sequences(@seq1, @seq2, callbacks) }
    assert_equal(@correct_lcs.size, callbacks.matched_a.size)
    assert_equal(@correct_lcs.size, callbacks.matched_b.size)
    assert_equal(@skipped_seq1, callbacks.discards_a.join(" "))
    assert_equal(@skipped_seq2, callbacks.discards_b.join(" "))
    assert_equal(9, callbacks.done_a[0][1])
    assert_nil(callbacks.done_b[0])
  end

  def test_diff
    diff = nil
    assert_nothing_raised { diff = Diff::LCS.diff(@seq1, @seq2) }
    assert_equal(__format_diffs(@correct_diff), __format_diffs(diff))
    assert_equal(@correct_diff, diff)
  end
end

class TestBalanced < TestDiffLCSBaseMethods
  undef :test_lcs

  def test_sdiff_a
    sdiff = nil
    seq1 = %w(abc def yyy xxx ghi jkl)
    seq2 = %w(abc dxf xxx ghi jkl)
    correct_sdiff = [
      ['=', [0, 'abc'], [0, 'abc']],
      ['!', [1, 'def'], [1, 'dxf']],
      ['-', [2, 'yyy'], [2, nil]],
      ['=', [3, 'xxx'], [2, 'xxx']],
      ['=', [4, 'ghi'], [3, 'ghi']],
      ['=', [5, 'jkl'], [4, 'jkl']] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_b
    sdiff = nil
    correct_sdiff = [
      ['-', [0, 'a'], [0, nil]],
      ['=', [1, 'b'], [0, 'b']],
      ['=', [2, 'c'], [1, 'c']],
      ['+', [3, nil], [2, 'd']],
      ['=', [3, 'e'], [3, 'e']],
      ['!', [4, 'h'], [4, 'f']],
      ['=', [5, 'j'], [5, 'j']],
      ['+', [6, nil], [6, 'k']],
      ['=', [6, 'l'], [7, 'l']],
      ['=', [7, 'm'], [8, 'm']],
      ['!', [8, 'n'], [9, 'r']],
      ['!', [9, 'p'], [10, 's']],
      ['+', [10, nil], [11, 't']] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(@seq1, @seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_c
    sdiff = nil
    seq1 = %w(a b c d e)
    seq2 = %w(a e)
    correct_sdiff = [
      ['=', [0, 'a'], [0, 'a'] ],
      ['-', [1, 'b'], [1, nil] ],
      ['-', [2, 'c'], [1, nil] ],
      ['-', [3, 'd'], [1, nil] ],
      ['=', [4, 'e'], [1, 'e'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_d
    sdiff = nil
    seq1 = %w(a e)
    seq2 = %w(a b c d e)
    correct_sdiff = [
      ['=', [0, 'a'], [0, 'a'] ],
      ['+', [1, nil], [1, 'b'] ],
      ['+', [1, nil], [2, 'c'] ],
      ['+', [1, nil], [3, 'd'] ],
      ['=', [1, 'e'], [4, 'e'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_e
    sdiff = nil
    seq1 = %w(v x a e)
    seq2 = %w(w y a b c d e)
    correct_sdiff = [
      ['!', [0, 'v'], [0, 'w'] ],
      ['!', [1, 'x'], [1, 'y'] ],
      ['=', [2, 'a'], [2, 'a'] ],
      ['+', [3, nil], [3, 'b'] ],
      ['+', [3, nil], [4, 'c'] ],
      ['+', [3, nil], [5, 'd'] ],
      ['=', [3, 'e'], [6, 'e'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_f
    sdiff = nil
    seq1 = %w(x a e)
    seq2 = %w(a b c d e)
    correct_sdiff = [
      ['-', [0, 'x'], [0, nil] ],
      ['=', [1, 'a'], [0, 'a'] ],
      ['+', [2, nil], [1, 'b'] ],
      ['+', [2, nil], [2, 'c'] ],
      ['+', [2, nil], [3, 'd'] ],
      ['=', [2, 'e'], [4, 'e'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_g
    sdiff = nil
    seq1 = %w(a e)
    seq2 = %w(x a b c d e)
    correct_sdiff = [
      ['+', [0, nil], [0, 'x'] ],
      ['=', [0, 'a'], [1, 'a'] ],
      ['+', [1, nil], [2, 'b'] ],
      ['+', [1, nil], [3, 'c'] ],
      ['+', [1, nil], [4, 'd'] ],
      ['=', [1, 'e'], [5, 'e'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_h
    sdiff = nil
    seq1 = %w(a e v)
    seq2 = %w(x a b c d e w x)
    correct_sdiff = [
      ['+', [0, nil], [0, 'x'] ],
      ['=', [0, 'a'], [1, 'a'] ],
      ['+', [1, nil], [2, 'b'] ],
      ['+', [1, nil], [3, 'c'] ],
      ['+', [1, nil], [4, 'd'] ],
      ['=', [1, 'e'], [5, 'e'] ],
      ['!', [2, 'v'], [6, 'w'] ],
      ['+', [3, nil], [7, 'x'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_i
    sdiff = nil
    seq1 = %w()
    seq2 = %w(a b c)
    correct_sdiff = [
      ['+', [0, nil], [0, 'a'] ],
      ['+', [0, nil], [1, 'b'] ],
      ['+', [0, nil], [2, 'c'] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_j
    sdiff = nil
    seq1 = %w(a b c)
    seq2 = %w()
    correct_sdiff = [
      ['-', [0, 'a'], [0, nil] ],
      ['-', [1, 'b'], [0, nil] ],
      ['-', [2, 'c'], [0, nil] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_k
    sdiff = nil
    seq1 = %w(a b c)
    seq2 = %w(1)
    correct_sdiff = [
      ['!', [0, 'a'], [0, '1'] ],
      ['-', [1, 'b'], [1, nil] ],
      ['-', [2, 'c'], [1, nil] ] ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_sdiff_l
    sdiff = nil
    seq1 = %w(a b c)
    seq2 = %w(c)
    correct_sdiff = [
      ['-', [0, 'a'], [0, nil] ],
      ['-', [1, 'b'], [0, nil] ],
      ['=', [2, 'c'], [0, 'c'] ]
    ]
    correct_sdiff = __map_diffs(correct_sdiff)
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff, sdiff)
  end

  def test_balanced_a
    seq1 = %w(a b c)
    seq2 = %w(a x c)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("M00 C11 M22 ", callback.result)
  end

  def test_balanced_b
    seq1 = %w(a b c)
    seq2 = %w(a x c)
    callback = nil
    assert_nothing_raised do
      callback = __balanced_callback
      class << callback
        undef change
      end
    end
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("M00 DA11 DB21 M22 ", callback.result)
  end

  def test_balanced_c
    seq1 = %w(a x y c)
    seq2 = %w(a v w c)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("M00 C11 C22 M33 ", callback.result)
  end

  def test_balanced_d
    seq1 = %w(x y c)
    seq2 = %w(v w c)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("C00 C11 M22 ", callback.result)
  end

  def test_balanced_e
    seq1 = %w(a x y z)
    seq2 = %w(b v w)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("C00 C11 C22 DA33 ", callback.result)
  end

  def test_balanced_f
    seq1 = %w(a z)
    seq2 = %w(a)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("M00 DA11 ", callback.result)
  end

  def test_balanced_g
    seq1 = %w(z a)
    seq2 = %w(a)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("DA00 M10 ", callback.result)
  end

  def test_balanced_h
    seq1 = %w(a b c)
    seq2 = %w(x y z)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("C00 C11 C22 ", callback.result)
  end
end
