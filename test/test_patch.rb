# frozen_string_literal: true

require_relative "test_helper"

class TestPatch < Minitest::Test
  def patch_sequences_correctly(s1, s2, patch_set)
    assert_equal s2, patch(s1, patch_set)
    assert_equal s2, patch(s1, patch_set, :patch)
    assert_equal s2, patch!(s1, patch_set)
    assert_equal s1, patch(s2, patch_set)
    assert_equal s1, patch(s2, patch_set, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set)
  end

  def test_diff_patchset_empty_returns_source_string
    diff = diff(hello, hello)
    assert_equal hello, patch(hello, diff)
  end

  def test_diff_patchset_empty_returns_source_array
    diff = diff(hello_ary, hello_ary)
    assert_equal hello_ary, patch(hello_ary, diff)
  end

  def test_diff_patchset_default_callbacks_forward
    patch_set = diff(seq1, seq2)
    patch_sequences_correctly(seq1, seq2, patch_set)
  end

  def test_diff_patchset_default_callbacks_reverse
    patch_set = diff(seq2, seq1)
    patch_sequences_correctly(seq2, seq1, patch_set)
  end

  def test_diff_patchset_context_callbacks_forward
    patch_set = diff(seq1, seq2, Diff::LCS::ContextDiffCallbacks)
    patch_sequences_correctly(seq1, seq2, patch_set)
  end

  def test_diff_patchset_context_callbacks_reverse
    patch_set = diff(seq2, seq1, Diff::LCS::ContextDiffCallbacks)
    patch_sequences_correctly(seq2, seq1, patch_set)
  end

  def test_diff_patchset_sdiff_callbacks_forward
    patch_set = diff(seq1, seq2, Diff::LCS::SDiffCallbacks)
    patch_sequences_correctly(seq1, seq2, patch_set)
  end

  def test_diff_patchset_sdiff_callbacks_reverse
    patch_set = diff(seq2, seq1, Diff::LCS::SDiffCallbacks)
    patch_sequences_correctly(seq2, seq1, patch_set)
  end

  def test_sdiff_patchset_empty_returns_source_string
    assert_equal hello, patch(hello, sdiff(hello, hello))
  end

  def test_sdiff_patchset_empty_returns_source_array
    assert_equal hello_ary, patch(hello_ary, sdiff(hello_ary, hello_ary))
  end

  def test_sdiff_patchset_diff_callbacks_forward
    patch_set = sdiff(seq1, seq2, Diff::LCS::DiffCallbacks)
    patch_sequences_correctly(seq1, seq2, patch_set)
  end

  def test_sdiff_patchset_diff_callbacks_reverse
    patch_set = sdiff(seq2, seq1, Diff::LCS::DiffCallbacks)
    patch_sequences_correctly(seq2, seq1, patch_set)
  end

  def test_sdiff_patchset_context_callbacks_forward
    patch_set = sdiff(seq1, seq2, Diff::LCS::ContextDiffCallbacks)
    patch_sequences_correctly(seq1, seq2, patch_set)
  end

  def test_sdiff_patchset_context_callbacks_reverse
    patch_set = sdiff(seq2, seq1, Diff::LCS::ContextDiffCallbacks)
    patch_sequences_correctly(seq2, seq1, patch_set)
  end

  def test_sdiff_patchset_sdiff_callbacks_forward
    patch_set = sdiff(seq1, seq2)
    patch_sequences_correctly(seq1, seq2, patch_set)
  end

  def test_sdiff_patchset_sdiff_callbacks_reverse
    patch_set = sdiff(seq2, seq1)
    patch_sequences_correctly(seq2, seq1, patch_set)
  end

  def test_bug_891_diff_default_callbacks_autodiscover_s1_to_s2
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = diff(s1, s2)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_diff_default_callbacks_autodiscover_s2_to_s1
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = diff(s2, s1)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_diff_default_callbacks_left_to_right
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2)
    patch_set_s2_s1 = diff(s2, s1)
    assert_equal s1, patch(s2, patch_set_s2_s1)
    assert_equal s1, patch(s2, patch_set_s1_s2)
  end

  def test_bug_891_diff_default_callbacks_explicit_patch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2)
    patch_set_s2_s1 = diff(s2, s1)
    assert_equal s2, patch(s1, patch_set_s1_s2, :patch)
    assert_equal s1, patch(s2, patch_set_s2_s1, :patch)
    assert_equal s2, patch!(s1, patch_set_s1_s2)
    assert_equal s1, patch!(s2, patch_set_s2_s1)
  end

  def test_bug_891_diff_default_callbacks_explicit_unpatch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2)
    patch_set_s2_s1 = diff(s2, s1)
    assert_equal s1, patch(s2, patch_set_s1_s2, :unpatch)
    assert_equal s2, patch(s1, patch_set_s2_s1, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set_s1_s2)
    assert_equal s2, unpatch!(s1, patch_set_s2_s1)
  end

  def test_bug_891_diff_context_callbacks_autodiscover_s1_to_s2
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = diff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_diff_context_callbacks_autodiscover_s2_to_s1
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = diff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_diff_context_callbacks_left_to_right
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    patch_set_s2_s1 = diff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s2_s1)
    assert_equal s1, patch(s2, patch_set_s1_s2)
  end

  def test_bug_891_diff_context_callbacks_explicit_patch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    patch_set_s2_s1 = diff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s2, patch(s1, patch_set_s1_s2, :patch)
    assert_equal s1, patch(s2, patch_set_s2_s1, :patch)
    assert_equal s2, patch!(s1, patch_set_s1_s2)
    assert_equal s1, patch!(s2, patch_set_s2_s1)
  end

  def test_bug_891_diff_context_callbacks_explicit_unpatch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    patch_set_s2_s1 = diff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s1_s2, :unpatch)
    assert_equal s2, patch(s1, patch_set_s2_s1, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set_s1_s2)
    assert_equal s2, unpatch!(s1, patch_set_s2_s1)
  end

  def test_bug_891_diff_sdiff_callbacks_autodiscover_s1_to_s2
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = diff(s1, s2, Diff::LCS::SDiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_diff_sdiff_callbacks_autodiscover_s2_to_s1
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = diff(s2, s1, Diff::LCS::SDiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_diff_sdiff_callbacks_left_to_right
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2, Diff::LCS::SDiffCallbacks)
    patch_set_s2_s1 = diff(s2, s1, Diff::LCS::SDiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s2_s1)
    assert_equal s1, patch(s2, patch_set_s1_s2)
  end

  def test_bug_891_diff_sdiff_callbacks_explicit_patch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2, Diff::LCS::SDiffCallbacks)
    patch_set_s2_s1 = diff(s2, s1, Diff::LCS::SDiffCallbacks)
    assert_equal s2, patch(s1, patch_set_s1_s2, :patch)
    assert_equal s1, patch(s2, patch_set_s2_s1, :patch)
    assert_equal s2, patch!(s1, patch_set_s1_s2)
    assert_equal s1, patch!(s2, patch_set_s2_s1)
  end

  def test_bug_891_diff_sdiff_callbacks_explicit_unpatch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = diff(s1, s2, Diff::LCS::SDiffCallbacks)
    patch_set_s2_s1 = diff(s2, s1, Diff::LCS::SDiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s1_s2, :unpatch)
    assert_equal s2, patch(s1, patch_set_s2_s1, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set_s1_s2)
    assert_equal s2, unpatch!(s1, patch_set_s2_s1)
  end

  def test_bug_891_sdiff_default_callbacks_autodiscover_s1_to_s2
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = sdiff(s1, s2)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_sdiff_default_callbacks_autodiscover_s2_to_s1
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = sdiff(s2, s1)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_sdiff_default_callbacks_left_to_right
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2)
    patch_set_s2_s1 = sdiff(s2, s1)
    assert_equal s1, patch(s2, patch_set_s2_s1)
    assert_equal s1, patch(s2, patch_set_s1_s2)
  end

  def test_bug_891_sdiff_default_callbacks_explicit_patch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2)
    patch_set_s2_s1 = sdiff(s2, s1)
    assert_equal s2, patch(s1, patch_set_s1_s2, :patch)
    assert_equal s1, patch(s2, patch_set_s2_s1, :patch)
    assert_equal s2, patch!(s1, patch_set_s1_s2)
    assert_equal s1, patch!(s2, patch_set_s2_s1)
  end

  def test_bug_891_sdiff_default_callbacks_explicit_unpatch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2)
    patch_set_s2_s1 = sdiff(s2, s1)
    assert_equal s1, patch(s2, patch_set_s1_s2, :unpatch)
    assert_equal s2, patch(s1, patch_set_s2_s1, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set_s1_s2)
    assert_equal s2, unpatch!(s1, patch_set_s2_s1)
  end

  def test_bug_891_sdiff_context_callbacks_autodiscover_s1_to_s2
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = sdiff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_sdiff_context_callbacks_autodiscover_s2_to_s1
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = sdiff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_sdiff_context_callbacks_left_to_right
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    patch_set_s2_s1 = sdiff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s2_s1)
    assert_equal s1, patch(s2, patch_set_s1_s2)
  end

  def test_bug_891_sdiff_context_callbacks_explicit_patch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    patch_set_s2_s1 = sdiff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s2, patch(s1, patch_set_s1_s2, :patch)
    assert_equal s1, patch(s2, patch_set_s2_s1, :patch)
    assert_equal s2, patch!(s1, patch_set_s1_s2)
    assert_equal s1, patch!(s2, patch_set_s2_s1)
  end

  def test_bug_891_sdiff_context_callbacks_explicit_unpatch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2, Diff::LCS::ContextDiffCallbacks)
    patch_set_s2_s1 = sdiff(s2, s1, Diff::LCS::ContextDiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s1_s2, :unpatch)
    assert_equal s2, patch(s1, patch_set_s2_s1, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set_s1_s2)
    assert_equal s2, unpatch!(s1, patch_set_s2_s1)
  end

  def test_bug_891_sdiff_diff_callbacks_autodiscover_s1_to_s2
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = sdiff(s1, s2, Diff::LCS::DiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_sdiff_diff_callbacks_autodiscover_s2_to_s1
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set = sdiff(s2, s1, Diff::LCS::DiffCallbacks)
    assert_equal s2, patch(s1, patch_set)
  end

  def test_bug_891_sdiff_diff_callbacks_left_to_right
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2, Diff::LCS::DiffCallbacks)
    patch_set_s2_s1 = sdiff(s2, s1, Diff::LCS::DiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s2_s1)
    assert_equal s1, patch(s2, patch_set_s1_s2)
  end

  def test_bug_891_sdiff_diff_callbacks_explicit_patch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2, Diff::LCS::DiffCallbacks)
    patch_set_s2_s1 = sdiff(s2, s1, Diff::LCS::DiffCallbacks)
    assert_equal s2, patch(s1, patch_set_s1_s2, :patch)
    assert_equal s1, patch(s2, patch_set_s2_s1, :patch)
    assert_equal s2, patch!(s1, patch_set_s1_s2)
    assert_equal s1, patch!(s2, patch_set_s2_s1)
  end

  def test_bug_891_sdiff_diff_callbacks_explicit_unpatch
    s1 = %w[a b c d   e f g h i j k] # standard:disable Layout/SpaceInsideArrayPercentLiteral
    s2 = %w[a b c d D e f g h i j k]
    patch_set_s1_s2 = sdiff(s1, s2, Diff::LCS::DiffCallbacks)
    patch_set_s2_s1 = sdiff(s2, s1, Diff::LCS::DiffCallbacks)
    assert_equal s1, patch(s2, patch_set_s1_s2, :unpatch)
    assert_equal s2, patch(s1, patch_set_s2_s1, :unpatch)
    assert_equal s1, unpatch!(s2, patch_set_s1_s2)
    assert_equal s2, unpatch!(s1, patch_set_s2_s1)
  end
end
