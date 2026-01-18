# frozen_string_literal: true

require_relative "test_helper"

class TestDiff < Minitest::Test
  def test_correctly_diffs_seq1_to_seq2
    assert_equal change_diff(correct_forward_diff), diff(seq1, seq2)
  end

  def test_correctly_diffs_seq2_to_seq1
    assert_equal change_diff(correct_backward_diff), diff(seq2, seq1)
  end

  def test_correctly_diffs_against_empty_sequence_forward
    correct_diff = [
      [
        ["-", 0, "abcd"],
        ["-", 1, "efgh"],
        ["-", 2, "ijkl"],
        ["-", 3, "mnopqrstuvwxyz"]
      ]
    ]

    assert_equal change_diff(correct_diff), diff(word_sequence, [])
  end

  def test_correctly_diffs_against_empty_sequence_backward
    correct_diff = [
      [
        ["+", 0, "abcd"],
        ["+", 1, "efgh"],
        ["+", 2, "ijkl"],
        ["+", 3, "mnopqrstuvwxyz"]
      ]
    ]

    assert_equal change_diff(correct_diff), diff([], word_sequence)
  end

  def test_correctly_diffs_xx_and_xaxb
    left = "xx"
    right = "xaxb"
    assert_equal right, patch(left, diff(left, right))
  end

  def test_returns_empty_diff_with_hello_hello
    assert_empty diff(hello, hello)
  end

  def test_returns_empty_diff_with_hello_ary_hello_ary
    assert_empty diff(hello_ary, hello_ary)
  end
end
