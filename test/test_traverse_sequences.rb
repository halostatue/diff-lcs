# frozen_string_literal: true

require_relative "test_helper"

class TestTraverseSequences < Minitest::Test
  def test_callback_with_no_finishers_over_seq1_seq2_has_correct_lcs_result_on_left_matches
    callback_s1_s2 = simple_callback_no_finishers
    traverse_sequences(seq1, seq2, callback_s1_s2)

    callback_s2_s1 = simple_callback_no_finishers
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal correct_lcs, callback_s1_s2.matched_a
    assert_equal correct_lcs, callback_s2_s1.matched_a
  end

  def test_callback_with_no_finishers_over_seq1_seq2_has_correct_lcs_result_on_right_matches
    callback_s1_s2 = simple_callback_no_finishers
    traverse_sequences(seq1, seq2, callback_s1_s2)

    callback_s2_s1 = simple_callback_no_finishers
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal correct_lcs, callback_s1_s2.matched_b
    assert_equal correct_lcs, callback_s2_s1.matched_b
  end

  def test_callback_with_no_finishers_over_seq1_seq2_has_correct_skipped_sequences_with_left_sequence
    callback_s1_s2 = simple_callback_no_finishers
    traverse_sequences(seq1, seq2, callback_s1_s2)

    callback_s2_s1 = simple_callback_no_finishers
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal skipped_seq1, callback_s1_s2.discards_a
    assert_equal skipped_seq2, callback_s2_s1.discards_a
  end

  def test_callback_with_no_finishers_over_seq1_seq2_has_correct_skipped_sequences_with_right_sequence
    callback_s1_s2 = simple_callback_no_finishers
    traverse_sequences(seq1, seq2, callback_s1_s2)

    callback_s2_s1 = simple_callback_no_finishers
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal skipped_seq2, callback_s1_s2.discards_b
    assert_equal skipped_seq1, callback_s2_s1.discards_b
  end

  def test_callback_with_no_finishers_over_seq1_seq2_does_not_have_done_markers
    callback_s1_s2 = simple_callback_no_finishers
    traverse_sequences(seq1, seq2, callback_s1_s2)

    callback_s2_s1 = simple_callback_no_finishers
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_empty callback_s1_s2.done_a
    assert_empty callback_s1_s2.done_b
    assert_empty callback_s2_s1.done_a
    assert_empty callback_s2_s1.done_b
  end

  def test_callback_with_no_finishers_over_hello_hello_has_correct_lcs_result_on_left_matches
    callback = simple_callback_no_finishers
    traverse_sequences(hello, hello, callback)

    assert_equal hello.chars, callback.matched_a
  end

  def test_callback_with_no_finishers_over_hello_hello_has_correct_lcs_result_on_right_matches
    callback = simple_callback_no_finishers
    traverse_sequences(hello, hello, callback)

    assert_equal hello.chars, callback.matched_b
  end

  def test_callback_with_no_finishers_over_hello_hello_has_correct_skipped_sequences_with_left_sequence
    callback = simple_callback_no_finishers
    traverse_sequences(hello, hello, callback)

    assert_empty callback.discards_a
  end

  def test_callback_with_no_finishers_over_hello_hello_has_correct_skipped_sequences_with_right_sequence
    callback = simple_callback_no_finishers
    traverse_sequences(hello, hello, callback)

    assert_empty callback.discards_b
  end

  def test_callback_with_no_finishers_over_hello_hello_does_not_have_done_markers
    callback = simple_callback_no_finishers
    traverse_sequences(hello, hello, callback)

    assert_empty callback.done_a
    assert_empty callback.done_b
  end

  def test_callback_with_no_finishers_over_hello_ary_hello_ary_has_correct_lcs_result_on_left_matches
    callback = simple_callback_no_finishers
    traverse_sequences(hello_ary, hello_ary, callback)

    assert_equal hello_ary, callback.matched_a
  end

  def test_callback_with_no_finishers_over_hello_ary_hello_ary_has_correct_lcs_result_on_right_matches
    callback = simple_callback_no_finishers
    traverse_sequences(hello_ary, hello_ary, callback)

    assert_equal hello_ary, callback.matched_b
  end

  def test_callback_with_no_finishers_over_hello_ary_hello_ary_has_correct_skipped_sequences_with_left_sequence
    callback = simple_callback_no_finishers
    traverse_sequences(hello_ary, hello_ary, callback)

    assert_empty callback.discards_a
  end

  def test_callback_with_no_finishers_over_hello_ary_hello_ary_has_correct_skipped_sequences_with_right_sequence
    callback = simple_callback_no_finishers
    traverse_sequences(hello_ary, hello_ary, callback)

    assert_empty callback.discards_b
  end

  def test_callback_with_no_finishers_over_hello_ary_hello_ary_does_not_have_done_markers
    callback = simple_callback_no_finishers
    traverse_sequences(hello_ary, hello_ary, callback)

    assert_empty callback.done_a
    assert_empty callback.done_b
  end

  def test_callback_with_finisher_has_correct_lcs_result_on_left_matches
    callback_s1_s2 = simple_callback
    traverse_sequences(seq1, seq2, callback_s1_s2)
    callback_s2_s1 = simple_callback
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal correct_lcs, callback_s1_s2.matched_a
    assert_equal correct_lcs, callback_s2_s1.matched_a
  end

  def test_callback_with_finisher_has_correct_lcs_result_on_right_matches
    callback_s1_s2 = simple_callback
    traverse_sequences(seq1, seq2, callback_s1_s2)
    callback_s2_s1 = simple_callback
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal correct_lcs, callback_s1_s2.matched_b
    assert_equal correct_lcs, callback_s2_s1.matched_b
  end

  def test_callback_with_finisher_has_correct_skipped_sequences_for_left_sequence
    callback_s1_s2 = simple_callback
    traverse_sequences(seq1, seq2, callback_s1_s2)
    callback_s2_s1 = simple_callback
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal skipped_seq1, callback_s1_s2.discards_a
    assert_equal skipped_seq2, callback_s2_s1.discards_a
  end

  def test_callback_with_finisher_has_correct_skipped_sequences_for_right_sequence
    callback_s1_s2 = simple_callback
    traverse_sequences(seq1, seq2, callback_s1_s2)
    callback_s2_s1 = simple_callback
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal skipped_seq2, callback_s1_s2.discards_b
    assert_equal skipped_seq1, callback_s2_s1.discards_b
  end

  def test_callback_with_finisher_has_done_markers_differently_sized_sequences
    callback_s1_s2 = simple_callback
    traverse_sequences(seq1, seq2, callback_s1_s2)
    callback_s2_s1 = simple_callback
    traverse_sequences(seq2, seq1, callback_s2_s1)

    assert_equal [["p", 9, "t", 11]], callback_s1_s2.done_a
    assert_empty callback_s1_s2.done_b

    assert_empty callback_s2_s1.done_a
    assert_equal [["t", 11, "p", 9]], callback_s2_s1.done_b
  end
end
