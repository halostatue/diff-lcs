# frozen_string_literal: true

require "test_helper"

require "diff/lcs/hunk"

class TestHunk < Minitest::Test
  def setup
    @old_data = ["Tu a un carté avec {count} itéms".encode("UTF-16LE")]
    @new_data = ["Tu a un carte avec {count} items".encode("UTF-16LE")]
    @pieces = diff(@old_data, @new_data)
    @hunk = hunk(@old_data, @new_data, @pieces[0], 3, 0)
  end

  def test_produces_a_unified_diff_from_the_two_pieces
    expected = <<-EXPECTED.gsub(/^\s+/, "").encode("UTF-16LE").chomp
        @@ -1 +1 @@
        -Tu a un carté avec {count} itéms
        +Tu a un carte avec {count} items
    EXPECTED

    assert_equal expected, @hunk.diff(:unified)
  end

  def test_produces_a_unified_diff_from_the_two_pieces_last_entry
    expected = <<-EXPECTED.gsub(/^\s+/, "").encode("UTF-16LE").chomp
        @@ -1 +1 @@
        -Tu a un carté avec {count} itéms
        +Tu a un carte avec {count} items
        \\ No newline at end of file
    EXPECTED

    assert_equal expected, @hunk.diff(:unified, true)
  end

  def test_produces_a_context_diff_from_the_two_pieces
    expected = <<-EXPECTED.gsub(/^\s+/, "").encode("UTF-16LE").chomp
        ***************
        *** 1 ****
        ! Tu a un carté avec {count} itéms
        --- 1 ----
        ! Tu a un carte avec {count} items
    EXPECTED

    assert_equal expected, @hunk.diff(:context)
  end

  def test_produces_an_old_diff_from_the_two_pieces
    expected = <<-EXPECTED.gsub(/^ +/, "").encode("UTF-16LE").chomp
        1c1
        < Tu a un carté avec {count} itéms
        ---
        > Tu a un carte avec {count} items

    EXPECTED

    assert_equal expected, @hunk.diff(:old)
  end

  def test_with_empty_first_data_set_produces_a_unified_diff
    old_data = []
    pieces = diff(old_data, @new_data)
    hunk = hunk(old_data, @new_data, pieces[0], 3, 0)

    expected = <<-EXPECTED.gsub(/^\s+/, "").encode("UTF-16LE").chomp
        @@ -0,0 +1 @@
        +Tu a un carte avec {count} items
    EXPECTED

    assert_equal expected, hunk.diff(:unified)
  end

  def test_from_diff_without_differences
    assert_empty Diff::LCS::Hunk.from_diff(numbered_lines, numbered_lines, 3)
  end

  def test_from_diff_without_context_has_one_hunk_per_difference
    hunks = Diff::LCS::Hunk.from_diff(numbered_lines, changed_numbered_lines, 0)

    assert_equal 3, hunks.size
    assert_equal [1, 1, 1], hunks.map { _1.blocks.size }
  end

  def test_from_diff_defaults_to_three_lines_of_context
    hunks = Diff::LCS::Hunk.from_diff(numbered_lines, changed_numbered_lines)

    assert_equal [[0, 9], [16, 19]], hunks.map { [_1.start_old, _1.end_old] }
  end

  def test_from_diff_rejects_invalid_context
    [nil, "3", -1, 1.5].each do |context|
      assert_raises_with_message(ArgumentError, "context must be a non-negative Integer") do
        Diff::LCS::Hunk.from_diff(numbered_lines, numbered_lines, context)
      end
    end
  end

  def test_old_diff_of_a_hunk_with_context_has_no_context
    old_data = (1..10).map { "#{_1}\n" }
    new_data = old_data.dup.tap { _1[4] = "x\n" }
    hunks = Diff::LCS::Hunk.from_diff(old_data, new_data, 2)

    assert_equal ["5c5\n< 5\n---\n> x\n"], hunks.map { _1.diff(:old, true) }
  end

  def test_old_diff_of_merged_hunks_writes_each_change
    hunks = Diff::LCS::Hunk.from_diff(numbered_lines, changed_numbered_lines, 3)

    assert_silent do
      assert_equal "3c3\n< 3\n---\n> three\n7c7\n< 7\n---\n> seven\n", hunks[0].diff(:old)
    end
  end

  def test_from_diff_merges_hunks_that_overlap_because_of_context
    hunks = Diff::LCS::Hunk.from_diff(numbered_lines, changed_numbered_lines, 3)

    assert_equal 2, hunks.size
    assert_equal [2, 1], hunks.map { _1.blocks.size }
    assert_equal [[0, 9], [16, 19]], hunks.map { [_1.start_old, _1.end_old] }
    assert_equal [[0, 9], [16, 20]], hunks.map { [_1.start_new, _1.end_new] }
  end

  def test_diff_without_differences
    %i[old unified context].each do |format|
      assert_equal "", Diff::LCS::Hunk.diff(numbered_lines, numbered_lines, format, 3)
    end
  end

  def test_diff_old
    expected = <<~EXPECTED
      3c3
      < 3
      ---
      > three
      7c7
      < 7
      ---
      > seven
      19a20
      > nineteen and a half
    EXPECTED

    assert_equal expected, Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines)
  end

  def test_diff_old_ignores_context
    assert_equal Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines, :old, 0),
      Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines, :old, 3)
  end

  def test_diff_defaults_to_three_lines_of_context
    %i[unified context].each do |format|
      assert_equal Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines, format, 3),
        Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines, format)
    end
  end

  def test_diff_rejects_invalid_context_without_differences
    assert_raises(ArgumentError) do
      Diff::LCS::Hunk.diff(numbered_lines, numbered_lines, :unified, nil)
    end
  end

  def test_diff_with_one_empty_string_is_an_empty_file
    assert_equal "@@ -0,0 +1 @@\n+a\n", Diff::LCS::Hunk.diff([""], ["a\n"], :unified)

    %i[old unified context].each do |format|
      assert_equal Diff::LCS::Hunk.diff([], ["a\n"], format), Diff::LCS::Hunk.diff([""], ["a\n"], format)
      assert_equal Diff::LCS::Hunk.diff(["a\n"], [], format), Diff::LCS::Hunk.diff(["a\n"], [""], format)
    end
  end

  def test_diff_old_marks_missing_newline_after_the_last_change_of_merged_hunks
    expected = <<~EXPECTED
      2c2
      < b
      ---
      > x
      4c4
      < d
      ---
      > y
      \\ No newline at end of file
    EXPECTED

    assert_equal expected, Diff::LCS::Hunk.diff(%W[a\n b\n c\n d\n], %W[a\n x\n c\n y], :old, 3)
  end

  def test_diff_unified
    expected = <<~EXPECTED
      @@ -1,10 +1,10 @@
       1
       2
      -3
      +three
       4
       5
       6
      -7
      +seven
       8
       9
       10
      @@ -17,4 +17,5 @@
       17
       18
       19
      +nineteen and a half
       20
    EXPECTED

    assert_equal expected, Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines, :unified, 3)
  end

  def test_diff_context
    expected = <<~EXPECTED
      ***************
      *** 1,10 ****
        1
        2
      ! 3
        4
        5
        6
      ! 7
        8
        9
        10
      --- 1,10 ----
        1
        2
      ! three
        4
        5
        6
      ! seven
        8
        9
        10
      ***************
      *** 17,20 ****
      --- 17,21 ----
        17
        18
        19
      + nineteen and a half
        20
    EXPECTED

    assert_equal expected, Diff::LCS::Hunk.diff(numbered_lines, changed_numbered_lines, :context, 3)
  end

  def test_diff_missing_newline_at_end_of_file
    expected = <<~EXPECTED
      @@ -1,2 +1,2 @@
       a
      -b
      +c
      \\ No newline at end of file
    EXPECTED

    assert_equal expected, Diff::LCS::Hunk.diff(["a\n", "b\n"], ["a\n", "c"], :unified, 3)
  end

  def test_diff_preserves_data_encoding
    newline = "\n".encode("UTF-16LE")
    expected = <<~EXPECTED.encode("UTF-16LE")
      @@ -1 +1 @@
      -Tu a un carté avec {count} itéms
      +Tu a un carte avec {count} items
    EXPECTED

    assert_equal expected,
      Diff::LCS::Hunk.diff(@old_data.map { _1 + newline }, @new_data.map { _1 + newline }, :unified, 3)
  end

  def test_diff_of_an_empty_string_and_lines_in_another_encoding
    new_data = ["é\n".encode("UTF-16LE")]

    assert_equal "@@ -0,0 +1 @@\n+é\n".encode("UTF-16LE"), Diff::LCS::Hunk.diff([""], new_data, :unified)
  end

  def test_diff_has_the_encoding_of_ascii_only_or_equal_data
    old_data = ["a\n", "b\n"].map { _1.encode("ISO-8859-1") }
    new_data = ["a\n", "c\n"].map { _1.encode("ISO-8859-1") }

    assert_equal Encoding::ISO_8859_1, Diff::LCS::Hunk.diff(old_data, new_data, :unified).encoding
    assert_equal Encoding::ISO_8859_1, Diff::LCS::Hunk.diff(old_data, old_data, :unified).encoding
  end

  def test_diff_unknown_format
    [changed_numbered_lines, numbered_lines].each do |new_data|
      assert_raises_with_message(RuntimeError, "Unknown diff format html.") do
        Diff::LCS::Hunk.diff(numbered_lines, new_data, :html)
      end
    end
  end

  private

  def numbered_lines = (1..20).map { "#{_1}\n" }

  def changed_numbered_lines
    numbered_lines.tap do
      _1[2] = "three\n"
      _1[6] = "seven\n"
      _1.insert(19, "nineteen and a half\n")
    end
  end
end
