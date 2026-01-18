# frozen_string_literal: true

require "test_helper"

class TestTraverseBalanced < Minitest::Test
  def balanced_traversal(s1, s2, callback_type)
    callback = send(callback_type)
    traverse_balanced(s1, s2, callback)
    callback
  end

  def balanced_reverse(change_result)
    new_result = []
    change_result.each do |line|
      line = [line[0], line[2], line[1]]
      case line[0]
      when "<"
        line[0] = ">"
      when ">"
        line[0] = "<"
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

  class BalancedCallback
    def initialize
      reset
    end

    attr_reader :result

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

  def balanced_callback
    BalancedCallback.new
  end

  class BalancedCallbackNoChange < BalancedCallback
    undef :change
  end

  def balanced_callback_no_change
    BalancedCallbackNoChange.new
  end

  def assert_traversal_with_change(s1, s2, result)
    traversal = balanced_traversal(s1, s2, :balanced_callback)
    assert_equal result, traversal.result

    traversal = balanced_traversal(s2, s1, :balanced_callback)
    assert_equal balanced_reverse(result), traversal.result
  end

  def assert_traversal_without_change(s1, s2, result)
    traversal = balanced_traversal(s1, s2, :balanced_callback_no_change)
    assert_equal map_to_no_change(result), traversal.result

    traversal = balanced_traversal(s2, s1, :balanced_callback_no_change)
    assert_equal map_to_no_change(balanced_reverse(result)), traversal.result
  end

  def test_identical_string_sequences_abc
    s1 = s2 = "abc"
    result = [
      ["=", 0, 0],
      ["=", 1, 1],
      ["=", 2, 2]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_identical_array_sequences_a_b_c
    s1 = s2 = %w[a b c]
    result = [
      ["=", 0, 0],
      ["=", 1, 1],
      ["=", 2, 2]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_a_b_c_and_a_x_c
    s1 = %w[a b c]
    s2 = %w[a x c]
    result = [
      ["=", 0, 0],
      ["!", 1, 1],
      ["=", 2, 2]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_a_x_y_c_and_a_v_w_c
    s1 = %w[a x y c]
    s2 = %w[a v w c]
    result = [
      ["=", 0, 0],
      ["!", 1, 1],
      ["!", 2, 2],
      ["=", 3, 3]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_x_y_c_and_v_w_c
    s1 = %w[x y c]
    s2 = %w[v w c]
    result = [
      ["!", 0, 0],
      ["!", 1, 1],
      ["=", 2, 2]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_a_x_y_z_and_b_v_w
    s1 = %w[a x y z]
    s2 = %w[b v w]
    result = [
      ["!", 0, 0],
      ["!", 1, 1],
      ["!", 2, 2],
      ["<", 3, 3]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_a_z_and_a
    s1 = %w[a z]
    s2 = %w[a]
    result = [
      ["=", 0, 0],
      ["<", 1, 1]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_z_a_and_a
    s1 = %w[z a]
    s2 = %w[a]
    result = [
      ["<", 0, 0],
      ["=", 1, 0]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_sequences_a_b_c_and_x_y_z
    s1 = %w[a b c]
    s2 = %w[x y z]
    result = [
      ["!", 0, 0],
      ["!", 1, 1],
      ["!", 2, 2]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_a_b_c_and_a_x_c
    s1 = "a b c"
    s2 = "a x c"
    result = [
      ["=", 0, 0],
      ["=", 1, 1],
      ["!", 2, 2],
      ["=", 3, 3],
      ["=", 4, 4]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_a_x_y_c_and_a_v_w_c
    s1 = "a x y c"
    s2 = "a v w c"
    result = [
      ["=", 0, 0],
      ["=", 1, 1],
      ["!", 2, 2],
      ["=", 3, 3],
      ["!", 4, 4],
      ["=", 5, 5],
      ["=", 6, 6]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_x_y_c_and_v_w_c
    s1 = "x y c"
    s2 = "v w c"
    result = [
      ["!", 0, 0],
      ["=", 1, 1],
      ["!", 2, 2],
      ["=", 3, 3],
      ["=", 4, 4]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_a_z_and_a
    s1 = "a z"
    s2 = "a"
    result = [
      ["=", 0, 0],
      ["<", 1, 1],
      ["<", 2, 1]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_z_a_and_a
    s1 = "z a"
    s2 = "a"
    result = [
      ["<", 0, 0],
      ["<", 1, 0],
      ["=", 2, 0]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_a_b_c_and_x_y_z
    s1 = "a b c"
    s2 = "x y z"
    result = [
      ["!", 0, 0],
      ["=", 1, 1],
      ["!", 2, 2],
      ["=", 3, 3],
      ["!", 4, 4]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end

  def test_strings_abcd_efgh_ijkl_mnopqrstuvwxyz_and_empty
    s1 = "abcd efgh ijkl mnopqrstuvwxyz"
    s2 = ""
    result = [
      ["<", 0, 0],
      ["<", 1, 0],
      ["<", 2, 0],
      ["<", 3, 0],
      ["<", 4, 0],
      ["<", 5, 0],
      ["<", 6, 0],
      ["<", 7, 0],
      ["<", 8, 0],
      ["<", 9, 0],
      ["<", 10, 0],
      ["<", 11, 0],
      ["<", 12, 0],
      ["<", 13, 0],
      ["<", 14, 0],
      ["<", 15, 0],
      ["<", 16, 0],
      ["<", 17, 0],
      ["<", 18, 0],
      ["<", 19, 0],
      ["<", 20, 0],
      ["<", 21, 0],
      ["<", 22, 0],
      ["<", 23, 0],
      ["<", 24, 0],
      ["<", 25, 0],
      ["<", 26, 0],
      ["<", 27, 0],
      ["<", 28, 0]
    ]
    assert_traversal_with_change(s1, s2, result)
    assert_traversal_without_change(s1, s2, result)
  end
end
