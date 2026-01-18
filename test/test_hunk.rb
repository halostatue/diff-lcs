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
end
