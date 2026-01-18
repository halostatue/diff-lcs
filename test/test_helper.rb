# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(__dir__, "../lib")

require "minitest/autorun"
require "simplecov"
require "simplecov-lcov"
require "open3"

require "diff/lcs"

module Diff::LCS::TestHelper
  def hello = "hello"
  def hello_ary = %w[h e l l o]
  def seq1 = %w[a b c e h j l m n p]
  def skipped_seq1 = %w[a h n p]
  def seq2 = %w[b c d e f j k l m r s t]
  def skipped_seq2 = %w[d f k r s t]
  def word_sequence = %w[abcd efgh ijkl mnopqrstuvwxyz]
  def correct_lcs = %w[b c e j l m]

  private def change(...) = Diff::LCS::Change.new(...)
  private def change_from_a(array, klass = Diff::LCS::Change) = klass.from_a(array)
  private def diff(...) = Diff::LCS.diff(...)
  private def hunk(...) = Diff::LCS::Hunk.new(...)
  private def internal_lcs(...) = Diff::LCS::Internals.lcs(...)
  private def lcs(...) = Diff::LCS.lcs(...)
  private def patch(...) = Diff::LCS.patch(...)
  private def patch!(...) = Diff::LCS.patch!(...)
  private def sdiff(...) = Diff::LCS.sdiff(...)
  private def traverse_balanced(...) = Diff::LCS.traverse_balanced(...)
  private def traverse_sequences(...) = Diff::LCS.traverse_sequences(...)
  private def unpatch(...) = Diff::LCS.unpatch(...)
  private def unpatch!(...) = Diff::LCS.unpatch!(...)
  private def valid_actions = Diff::LCS::Change::VALID_ACTIONS

  def correct_forward_diff
    [
      [["-", 0, "a"]],
      [["+", 2, "d"]],
      [["-", 4, "h"], ["+", 4, "f"]],
      [["+", 6, "k"]],
      [["-", 8, "n"], ["+", 9, "r"], ["-", 9, "p"], ["+", 10, "s"], ["+", 11, "t"]]
    ]
  end

  def correct_backward_diff
    [
      [["+", 0, "a"]],
      [["-", 2, "d"]],
      [["-", 4, "f"], ["+", 4, "h"]],
      [["-", 6, "k"]],
      [["-", 9, "r"], ["+", 8, "n"], ["-", 10, "s"], ["+", 9, "p"], ["-", 11, "t"]]
    ]
  end

  def correct_forward_sdiff
    [
      ["-", [0, "a"], [0, nil]],
      ["=", [1, "b"], [0, "b"]],
      ["=", [2, "c"], [1, "c"]],
      ["+", [3, nil], [2, "d"]],
      ["=", [3, "e"], [3, "e"]],
      ["!", [4, "h"], [4, "f"]],
      ["=", [5, "j"], [5, "j"]],
      ["+", [6, nil], [6, "k"]],
      ["=", [6, "l"], [7, "l"]],
      ["=", [7, "m"], [8, "m"]],
      ["!", [8, "n"], [9, "r"]],
      ["!", [9, "p"], [10, "s"]],
      ["+", [10, nil], [11, "t"]]
    ]
  end

  def reverse_sdiff(forward_sdiff)
    forward_sdiff.map { |line|
      line[1], line[2] = line[2], line[1]
      case line[0]
      when "-" then line[0] = "+"
      when "+" then line[0] = "-"
      end
      line
    }
  end

  def change_diff(diff) = map_diffs(diff, Diff::LCS::Change)
  def context_diff(diff) = map_diffs(diff, Diff::LCS::ContextChange)

  def map_diffs(diffs, klass = Diff::LCS::ContextChange)
    diffs.map do |chunks|
      if klass == Diff::LCS::ContextChange
        klass.from_a(chunks)
      else
        chunks.map { |changes| klass.from_a(changes) }
      end
    end
  end

  def balanced_traversal(s1, s2, callback_type)
    callback = __send__(callback_type)
    Diff::LCS.traverse_balanced(s1, s2, callback)
    callback
  end

  def balanced_reverse(change_result)
    new_result = []
    change_result.each do |line|
      line = [line[0], line[2], line[1]]
      case line[0]
      when "<" then line[0] = ">"
      when ">" then line[0] = "<"
      end
      new_result << line
    end
    new_result.sort_by { |line| [line[1], line[2]] }
  end

  def map_to_no_change(change_result)
    new_result = []
    change_result.each do |line|
      case line[0]
      when "!"
        new_result << ["<", line[1], line[2]]
        new_result << [">", line[1] + 1, line[2]]
      else
        new_result << line
      end
    end
    new_result
  end

  def assert_nil_or_match_values(ee, ii, s1, s2)
    assert(ee.nil? || s1[ii] == s2[ee])
  end

  def assert_correctly_maps_sequence(actual, s1, s2)
    actual.each_index { |ii| assert_nil_or_match_values(actual[ii], ii, s1, s2) }
  end

  class SimpleCallback
    attr_reader :matched_a, :matched_b, :discards_a, :discards_b, :done_a, :done_b

    def initialize
      reset
    end

    def reset
      @matched_a = []
      @matched_b = []
      @discards_a = []
      @discards_b = []
      @done_a = []
      @done_b = []
      self
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
      @done_a << [event.old_element, event.old_position, event.new_element, event.new_position]
    end

    def finished_b(event)
      @done_b << [event.old_element, event.old_position, event.new_element, event.new_position]
    end
  end

  def simple_callback = SimpleCallback.new

  class SimpleCallbackNoFinishers < SimpleCallback
    undef :finished_a
    undef :finished_b
  end

  def simple_callback_no_finishers = SimpleCallbackNoFinishers.new

  class BalancedCallback
    attr_reader :result

    def initialize
      reset
    end

    def reset
      @result = []
    end

    def match(event)
      @result << ["=", event.old_position, event.new_position]
    end

    def discard_a(event)
      @result << ["<", event.old_position, event.new_position]
    end

    def discard_b(event)
      @result << [">", event.old_position, event.new_position]
    end

    def change(event)
      @result << ["!", event.old_position, event.new_position]
    end
  end

  def balanced_callback = BalancedCallback.new

  class BalancedCallbackNoChange < BalancedCallback
    undef :change
  end

  def balanced_callback_no_change = BalancedCallbackNoChange.new

  Minitest::Test.send(:include, self)
end
