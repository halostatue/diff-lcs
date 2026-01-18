# frozen_string_literal: true

require "test_helper"
require "diff/lcs/hunk"

class TestIssues < Minitest::Test
  def test_issue_1_string_forward_diff
    s1 = "aX"
    s2 = "bXaX"
    forward_diff = [
      [
        ["+", 0, "b"],
        ["+", 1, "X"]
      ]
    ]

    diff_s1_s2 = diff(s1, s2)

    assert_equal change_diff(forward_diff), diff_s1_s2
    assert_equal s2, patch(s1, diff_s1_s2)
    assert_equal s1, patch(s2, diff_s1_s2)
  end

  def test_issue_1_string_reverse_diff
    s1 = "bXaX"
    s2 = "aX"
    forward_diff = [
      [
        ["-", 0, "b"],
        ["-", 1, "X"]
      ]
    ]

    diff_s1_s2 = diff(s1, s2)

    assert_equal change_diff(forward_diff), diff_s1_s2
    assert_equal s2, patch(s1, diff_s1_s2)
    assert_equal s1, patch(s2, diff_s1_s2)
  end

  def test_issue_1_array_forward_diff
    s1 = %w[a X]
    s2 = %w[b X a X]
    forward_diff = [
      [
        ["+", 0, "b"],
        ["+", 1, "X"]
      ]
    ]

    diff_s1_s2 = diff(s1, s2)

    assert_equal change_diff(forward_diff), diff_s1_s2
    assert_equal s2, patch(s1, diff_s1_s2)
    assert_equal s1, patch(s2, diff_s1_s2)
  end

  def test_issue_1_array_reverse_diff
    s1 = %w[b X a X]
    s2 = %w[a X]
    forward_diff = [
      [
        ["-", 0, "b"],
        ["-", 1, "X"]
      ]
    ]

    diff_s1_s2 = diff(s1, s2)

    assert_equal change_diff(forward_diff), diff_s1_s2
    assert_equal s2, patch(s1, diff_s1_s2)
    assert_equal s1, patch(s2, diff_s1_s2)
  end

  def test_issue_57_should_fail_with_correct_error
    assert_raises(Minitest::Assertion) do
      actual = {category: "app.rack.request"}
      expected = {category: "rack.middleware", title: "Anonymous Middleware"}
      assert_equal expected, actual
    end
  end

  def diff_lines(old_lines, new_lines)
    file_length_difference = 0
    previous_hunk = nil
    output = []

    diff(old_lines, new_lines).each do |piece|
      hunk = hunk(old_lines, new_lines, piece, 3, file_length_difference)
      file_length_difference = hunk.file_length_difference
      maybe_contiguous_hunks = previous_hunk.nil? || hunk.merge(previous_hunk)

      output << "#{previous_hunk.diff(:unified)}\n" unless maybe_contiguous_hunks

      previous_hunk = hunk
    end
    output << "#{previous_hunk.diff(:unified, true)}\n" unless previous_hunk.nil?
    output.join
  end

  def test_issue_65_should_not_misplace_new_chunk
    old_data = [
      "recipe[a::default]", "recipe[b::default]", "recipe[c::default]",
      "recipe[d::default]", "recipe[e::default]", "recipe[f::default]",
      "recipe[g::default]", "recipe[h::default]", "recipe[i::default]",
      "recipe[j::default]", "recipe[k::default]", "recipe[l::default]",
      "recipe[m::default]", "recipe[n::default]"
    ]

    new_data = [
      "recipe[a::default]", "recipe[c::default]", "recipe[d::default]",
      "recipe[e::default]", "recipe[f::default]", "recipe[g::default]",
      "recipe[h::default]", "recipe[i::default]", "recipe[j::default]",
      "recipe[k::default]", "recipe[l::default]", "recipe[m::default]",
      "recipe[n::default]", "recipe[o::new]", "recipe[p::new]",
      "recipe[q::new]", "recipe[r::new]"
    ]

    expected = <<~EODIFF
      @@ -1,5 +1,4 @@
       recipe[a::default]
      -recipe[b::default]
       recipe[c::default]
       recipe[d::default]
       recipe[e::default]
      @@ -12,3 +11,7 @@
       recipe[l::default]
       recipe[m::default]
       recipe[n::default]
      +recipe[o::new]
      +recipe[p::new]
      +recipe[q::new]
      +recipe[r::new]
    EODIFF

    assert_equal expected, diff_lines(old_data, new_data)
  end

  def test_issue_107_should_produce_unified_output_with_correct_context
    old_data = <<~DATA_OLD.strip.split("\n").map(&:chomp)
      {
        "name": "x",
        "description": "hi"
      }
    DATA_OLD

    new_data = <<~DATA_NEW.strip.split("\n").map(&:chomp)
      {
        "name": "x",
        "description": "lo"
      }
    DATA_NEW

    diff = diff(old_data, new_data)
    hunk = hunk(old_data, new_data, diff.first, 3, 0)

    expected = <<~EXPECTED.chomp
      @@ -1,4 +1,4 @@
       {
         "name": "x",
      -  "description": "hi"
      +  "description": "lo"
       }
    EXPECTED

    assert_equal expected, hunk.diff(:unified)
  end
end
