#! /usr/bin/env ruby
#
$:.unshift '../lib' if __FILE__ == $0 # Make this library first!

require 'diff/lcs'
require 'test/unit'
require 'pp'
require 'diff/lcs/array'

module Diff::LCS::Tests
  def __format_diffs(diffs)
    diffs.map do |e|
      if e.kind_of?(Array)
        e.map { |f| f.to_a.join }.join(", ")
      else
        e.to_a.join
      end
    end.join("; ")
  end

  def __map_diffs(diffs, klass = Diff::LCS::Change)
    diffs.map do |chunks|
      chunks.map { |changes| klass.from_a(*changes) }
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

  def __balanced_callback
    cb = Object.new
    class << cb
      attr_reader :result

      def reset
        @result = ""
      end

      def match(event)
        @result << "M#{event.old_ix}#{event.new_ix} "
      end

      def discard_a(event)
        @result << "DA#{event.old_ix}#{event.new_ix} "
      end

      def discard_b(event)
        @result << "DB#{event.old_ix}#{event.new_ix} "
      end

      def change(event)
        @result << "C#{event.old_ix}#{event.new_ix} "
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
        [ '-',  9, 'p' ],
        [ '+',  9, 'r' ],
        [ '+', 10, 's' ],
        [ '+', 11, 't' ] ] ]
    @correct_diff = __map_diffs(correct_diff, Diff::LCS::Change)
  end
end

class TestLCS < Test::Unit::TestCase
  include Diff::LCS::Tests

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

class TestSequences < Test::Unit::TestCase
  include Diff::LCS::Tests

  def test_sequences
    callbacks = nil
    assert_nothing_raised do
      callbacks = __simple_callbacks
      class << callbacks
        undef :finished_a
        undef :finished_b
      end
      Diff::LCS.traverse_sequences(@seq1, @seq2, callbacks)
    end
    assert_equal(@correct_lcs.size, callbacks.matched_a.size)
    assert_equal(@correct_lcs.size, callbacks.matched_b.size)
    assert_equal(@skipped_seq1, callbacks.discards_a.join(" "))
    assert_equal(@skipped_seq2, callbacks.discards_b.join(" "))
    assert_nothing_raised do
      callbacks = __simple_callbacks
      Diff::LCS.traverse_sequences(@seq1, @seq2, callbacks)
    end
    assert_equal(@correct_lcs.size, callbacks.matched_a.size)
    assert_equal(@correct_lcs.size, callbacks.matched_b.size)
    assert_equal(@skipped_seq1, callbacks.discards_a.join(" "))
    assert_equal(@skipped_seq2, callbacks.discards_b.join(" "))
    assert_equal(9, callbacks.done_a[0][1])
    assert_nil(callbacks.done_b[0])

#   seqw = %w(abcd efgh ijkl mnopqrstuvwxyz)
#   assert_nothing_raised do
#     callbacks = __simple_callbacks
#     class << callbacks
#       undef :finished_a
#       undef :finished_b
#     end
#     Diff::LCS.traverse_sequences(seqw, [], callbacks)
#   end
  end

  def test_diff
    diff = nil
    assert_nothing_raised { diff = Diff::LCS.diff(@seq1, @seq2) }
    assert_equal(__format_diffs(@correct_diff), __format_diffs(diff))
    assert_equal(@correct_diff, diff)
  end

  def test_diff_empty
    seqw = %w(abcd efgh ijkl mnopqrstuvwxyz)
    correct_diff = [
      [ [ '-', 0, 'abcd'           ],
        [ '-', 1, 'efgh'           ],
        [ '-', 2, 'ijkl'           ],
        [ '-', 3, 'mnopqrstuvwxyz' ] ] ]
    diff = nil

    assert_nothing_raised { diff = Diff::LCS.diff(seqw, []) }
    assert_equal(__format_diffs(correct_diff), __format_diffs(diff))

    correct_diff = [
      [ [ '+', 0, 'abcd'           ],
        [ '+', 1, 'efgh'           ],
        [ '+', 2, 'ijkl'           ],
        [ '+', 3, 'mnopqrstuvwxyz' ] ] ]
    assert_nothing_raised { diff = Diff::LCS.diff([], seqw) }
    assert_equal(__format_diffs(correct_diff), __format_diffs(diff))
  end
end

class TestBalanced < Test::Unit::TestCase
  include Diff::LCS::Tests

  def test_sdiff_a
    sdiff = nil
    seq1 = %w(abc def yyy xxx ghi jkl)
    seq2 = %w(abc dxf xxx ghi jkl)
    correct_sdiff = [
      [ 'u', 'abc', 'abc' ],
      [ '!', 'def', 'dxf' ],
      [ '-', 'yyy',  nil  ],
      [ 'u', 'xxx', 'xxx' ],
      [ 'u', 'ghi', 'ghi' ],
      [ 'u', 'jkl', 'jkl' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_b
    sdiff = nil
    correct_sdiff = [
      [ '-', 'a', nil ],
      [ 'u', 'b', 'b' ],
      [ 'u', 'c', 'c' ],
      [ '+', nil, 'd' ],
      [ 'u', 'e', 'e' ],
      [ '!', 'h', 'f' ],
      [ 'u', 'j', 'j' ],
      [ '+', nil, 'k' ],
      [ 'u', 'l', 'l' ],
      [ 'u', 'm', 'm' ],
      [ '!', 'n', 'r' ],
      [ '!', 'p', 's' ],
      [ '+', nil, 't' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(@seq1, @seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_c
    sdiff = nil
    seq1 = %w(a b c d e)
    seq2 = %w(a e)
    correct_sdiff = [
      [ 'u', 'a', 'a' ],
      [ '-', 'b', nil ],
      [ '-', 'c', nil ],
      [ '-', 'd', nil ],
      [ 'u', 'e', 'e' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_d
    sdiff = nil
    seq1 = %w(a e)
    seq2 = %w(a b c d e)
    correct_sdiff = [
      [ 'u', 'a', 'a' ],
      [ '+', nil, 'b' ],
      [ '+', nil, 'c' ],
      [ '+', nil, 'd' ],
      [ 'u', 'e', 'e' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_e
    sdiff = nil
    seq1 = %w(v x a e)
    seq2 = %w(w y a b c d e)
    correct_sdiff = [
      [ '!', 'v', 'w' ],
      [ '!', 'x', 'y' ],
      [ 'u', 'a', 'a' ],
      [ '+', nil, 'b' ],
      [ '+', nil, 'c' ],
      [ '+', nil, 'd' ],
      [ 'u', 'e', 'e' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_f
    sdiff = nil
    seq1 = %w(x a e)
    seq2 = %w(a b c d e)
    correct_sdiff = [
      [ '-', 'x', nil ],
      [ 'u', 'a', 'a' ],
      [ '+', nil, 'b' ],
      [ '+', nil, 'c' ],
      [ '+', nil, 'd' ],
      [ 'u', 'e', 'e' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_g
    sdiff = nil
    seq1 = %w(a e)
    seq2 = %w(x a b c d e)
    correct_sdiff = [
      [ '+', nil, 'x' ],
      [ 'u', 'a', 'a' ],
      [ '+', nil, 'b' ],
      [ '+', nil, 'c' ],
      [ '+', nil, 'd' ],
      [ 'u', 'e', 'e' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_h
    sdiff = nil
    seq1 = %w(a e v)
    seq2 = %w(x a b c d e w x)
    correct_sdiff = [
      [ '+', nil, 'x' ],
      [ 'u', 'a', 'a' ],
      [ '+', nil, 'b' ],
      [ '+', nil, 'c' ],
      [ '+', nil, 'd' ],
      [ 'u', 'e', 'e' ],
      [ '!', 'v', 'w' ],
      [ '+', nil, 'x' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_i
    sdiff = nil
    seq1 = %w()
    seq2 = %w(a b c)
    correct_sdiff = [
      [ '+', nil, 'a' ],
      [ '+', nil, 'b' ],
      [ '+', nil, 'c' ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_j
    sdiff = nil
    seq1 = %w(a b c)
    seq2 = %w()
    correct_sdiff = [
      [ '-', 'a', nil ],
      [ '-', 'b', nil ],
      [ '-', 'c', nil ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_k
    sdiff = nil
    seq1 = %w(a b c)
    seq2 = %w(1)
    correct_sdiff = [
      [ '!', 'a', '1' ],
      [ '-', 'b', nil ],
      [ '-', 'c', nil ] ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_l
    sdiff = nil
    seq1 = %w(a b c)
    seq2 = %w(c)
    correct_sdiff = [
      [ '-', 'a', nil ],
      [ '-', 'b', nil ],
      [ 'u', 'c', 'c' ]
    ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_m
    sdiff = nil
    seq1 = %w(abcd efgh ijkl mnop)
    seq2 = []
    correct_sdiff = [
      [ '-', 'abcd', nil ],
      [ '-', 'efgh', nil ],
      [ '-', 'ijkl', nil ],
      [ '-', 'mnop', nil ]
    ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
  end

  def test_sdiff_n
    sdiff = nil
    seq1 = []
    seq2 = %w(abcd efgh ijkl mnop)
    correct_sdiff = [
      [ '+', nil, 'abcd' ],
      [ '+', nil, 'efgh' ],
      [ '+', nil, 'ijkl' ],
      [ '+', nil, 'mnop' ]
    ]
    correct_sdiff = __map_diffs([correct_sdiff])
    assert_nothing_raised { sdiff = Diff::LCS.sdiff(seq1, seq2) }
    assert_equal(correct_sdiff[0], sdiff)
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

  def test_balanced_i
    seq1 = %w(abcd efgh ijkl mnopqrstuvwxyz)
    seq2 = []
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("DA00 DA10 DA20 DA30 ", callback.result)
  end

  def test_balanced_j
    seq1 = []
    seq2 = %w(abcd efgh ijkl mnopqrstuvwxyz)
    callback = nil
    assert_nothing_raised { callback = __balanced_callback }
    assert_nothing_raised { Diff::LCS.traverse_balanced(seq1, seq2, callback) }
    assert_equal("DB00 DB01 DB02 DB03 ", callback.result)
  end
end
