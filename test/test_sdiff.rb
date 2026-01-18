# frozen_string_literal: true

require_relative "test_helper"

class TestSDiff < Minitest::Test
  def compare_sequences_correctly(s1, s2, result)
    assert_equal context_diff(result), sdiff(s1, s2)
    assert_equal context_diff(reverse_sdiff(result)), sdiff(s2, s1)
  end

  def test_seq1_seq2
    compare_sequences_correctly(seq1, seq2, correct_forward_sdiff)
  end

  def test_abc_def_yyy_xxx_ghi_jkl
    s1 = %w[abc def yyy xxx ghi jkl]
    s2 = %w[abc dxf xxx ghi jkl]
    result = [
      ["=", [0, "abc"], [0, "abc"]],
      ["!", [1, "def"], [1, "dxf"]],
      ["-", [2, "yyy"], [2, nil]],
      ["=", [3, "xxx"], [2, "xxx"]],
      ["=", [4, "ghi"], [3, "ghi"]],
      ["=", [5, "jkl"], [4, "jkl"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_a_b_c_d_e_vs_a_e
    s1 = %w[a b c d e]
    s2 = %w[a e]
    result = [
      ["=", [0, "a"], [0, "a"]],
      ["-", [1, "b"], [1, nil]],
      ["-", [2, "c"], [1, nil]],
      ["-", [3, "d"], [1, nil]],
      ["=", [4, "e"], [1, "e"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_a_e_vs_a_b_c_d_e
    s1 = %w[a e]
    s2 = %w[a b c d e]
    result = [
      ["=", [0, "a"], [0, "a"]],
      ["+", [1, nil], [1, "b"]],
      ["+", [1, nil], [2, "c"]],
      ["+", [1, nil], [3, "d"]],
      ["=", [1, "e"], [4, "e"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_v_x_a_e_vs_w_y_a_b_c_d_e
    s1 = %w[v x a e]
    s2 = %w[w y a b c d e]
    result = [
      ["!", [0, "v"], [0, "w"]],
      ["!", [1, "x"], [1, "y"]],
      ["=", [2, "a"], [2, "a"]],
      ["+", [3, nil], [3, "b"]],
      ["+", [3, nil], [4, "c"]],
      ["+", [3, nil], [5, "d"]],
      ["=", [3, "e"], [6, "e"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_x_a_e_vs_a_b_c_d_e
    s1 = %w[x a e]
    s2 = %w[a b c d e]
    result = [
      ["-", [0, "x"], [0, nil]],
      ["=", [1, "a"], [0, "a"]],
      ["+", [2, nil], [1, "b"]],
      ["+", [2, nil], [2, "c"]],
      ["+", [2, nil], [3, "d"]],
      ["=", [2, "e"], [4, "e"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_a_e_vs_x_a_b_c_d_e
    s1 = %w[a e]
    s2 = %w[x a b c d e]
    result = [
      ["+", [0, nil], [0, "x"]],
      ["=", [0, "a"], [1, "a"]],
      ["+", [1, nil], [2, "b"]],
      ["+", [1, nil], [3, "c"]],
      ["+", [1, nil], [4, "d"]],
      ["=", [1, "e"], [5, "e"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_a_e_v_vs_x_a_b_c_d_e_w_x
    s1 = %w[a e v]
    s2 = %w[x a b c d e w x]
    result = [
      ["+", [0, nil], [0, "x"]],
      ["=", [0, "a"], [1, "a"]],
      ["+", [1, nil], [2, "b"]],
      ["+", [1, nil], [3, "c"]],
      ["+", [1, nil], [4, "d"]],
      ["=", [1, "e"], [5, "e"]],
      ["!", [2, "v"], [6, "w"]],
      ["+", [3, nil], [7, "x"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_empty_vs_a_b_c
    s1 = %w[]
    s2 = %w[a b c]
    result = [
      ["+", [0, nil], [0, "a"]],
      ["+", [0, nil], [1, "b"]],
      ["+", [0, nil], [2, "c"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_a_b_c_vs_1
    s1 = %w[a b c]
    s2 = %w[1]
    result = [
      ["!", [0, "a"], [0, "1"]],
      ["-", [1, "b"], [1, nil]],
      ["-", [2, "c"], [1, nil]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_a_b_c_vs_c
    s1 = %w[a b c]
    s2 = %w[c]
    result = [
      ["-", [0, "a"], [0, nil]],
      ["-", [1, "b"], [0, nil]],
      ["=", [2, "c"], [0, "c"]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_abcd_efgh_ijkl_mnop_vs_empty
    s1 = %w[abcd efgh ijkl mnop]
    s2 = []
    result = [
      ["-", [0, "abcd"], [0, nil]],
      ["-", [1, "efgh"], [0, nil]],
      ["-", [2, "ijkl"], [0, nil]],
      ["-", [3, "mnop"], [0, nil]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end

  def test_nested_array_vs_empty
    s1 = [[1, 2]]
    s2 = []
    result = [
      ["-", [0, [1, 2]], [0, nil]]
    ]
    compare_sequences_correctly(s1, s2, result)
  end
end
