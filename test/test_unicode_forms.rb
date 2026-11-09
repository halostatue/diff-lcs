# frozen_string_literal: true

require "test_helper"
require "diff/lcs/hunk"

# diff-lcs compares strings by codepoint (String#chars), not grapheme clusters
# (String#grapheme_clusters). It _does not normalize Unicode input_, so NFC characters
# ("e" U+00E9 => "é") and the canonical NFD forms ("e" U+0065 + combining acute U+0301)
# are reported as a difference.
#
# These tests mark this as intentional, not accidental. Normalizing before diffing is the
# caller's responsibility.
class TestUnicodeForms < Minitest::Test
  # The sentence is a French pangram exercising nearly every accented glyph. "œ" and "æ"
  # have no canonical decomposition, so they are identical in both forms and correctly
  # contribute no differences.
  NFC_NFD_PANGRAM =
    "D\u00e8s No\u00ebl o\u00f9 un z\u00e9phyr ha\u00ef me v\u00eat de " \
    "gla\u00e7ons w\u00fcrmiens je d\u00eene d'exquis r\u00f4tis de b\u0153uf " \
    "au kir \u00e0 l'a\u00ff d'\u00e2ge m\u00fbr & c\u00e6tera"

  # The 14 characters that differ between the two forms, in order of appearance.
  NFC_NFD_DECOMPOSABLE = %w[è ë ù é ï ê ç ü î ô à ÿ â û].freeze

  # The Unicode tests are against sequences, not strings:
  #
  # - characters
  # - grapheme clusters
  # - words

  def test_nfc_and_nfd_are_unequal_input
    nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).chars
    nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).chars

    refute_equal nfc, nfd
  end

  def test_nfc_nfd_diff_deletes_precomposed_and_inserts_decomposition
    nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).chars
    nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).chars

    result = diff(nfc, nfd)

    assert_equal NFC_NFD_DECOMPOSABLE.size, result.size

    deleted = result.map { |chunk| chunk.select { |c| c.action == "-" }.map(&:element).join }
    assert_equal NFC_NFD_DECOMPOSABLE, deleted

    # Each chunk removes exactly the one precomposed character and inserts its
    # decomposition (base letter plus one or more combining marks).
    result.each do |chunk|
      assert_equal 1, chunk.count { |c| c.action == "-" }
      assert_operator chunk.count { |c| c.action == "+" }, :>=, 1
    end
  end

  def test_nfc_nfd_diff_patches_in_both_directions
    nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).chars
    nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).chars

    result = diff(nfc, nfd)

    assert_equal nfd, patch(nfc, result)
    assert_equal nfc, patch(nfd, result)
  end

  def test_nfc_nfd_sdiff_reports_changes_only_for_decomposable_characters
    nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).chars
    nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).chars

    result = sdiff(nfc, nfd)

    changed = result.select { |c| c.action == "!" }.map(&:old_element).join
    assert_equal NFC_NFD_DECOMPOSABLE.join, changed

    # Nothing marked unchanged should actually differ.
    result.select { |c| c.action == "=" }.each do |c|
      assert_equal c.old_element, c.new_element
    end
  end

  def test_nfc_nfd_sdiff_patches_in_both_directions
    nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).chars
    nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).chars

    result = sdiff(nfc, nfd)

    assert_equal nfd, patch(nfc, result)
    assert_equal nfc, patch(nfd, result)
  end

  def test_nfc_nfd_unified_diff_renders_decomposition
    nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).chars
    nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).chars

    result = diff(nfc, nfd)
    hunk = hunk(nfc, nfd, result.first, 1, 0)

    # "è" (U+00E8) decomposes to "e" (U+0065) + combining grave accent (U+0300). The \u
    # escapes keep the NFC "-" line and the NFD "+" lines visually distinct.
    expected = <<~DIFF.chomp
      @@ -1,3 +1,4 @@
       D
      -\u00e8
      +e
      +\u0300
       s
    DIFF

    assert_equal expected, hunk.diff(:unified)
  end

  # Grapheme clusters (String#grapheme_clusters) splits `Dés` into `["D", "\u00e8", "s"]`
  # for NFC (same as String#chars), but `["D", "\e\u0300", "s"]` for NFD. Now the
  # sequences have the same length and align 1:1. Each accented grapheme remains a
  # distinct change.
  def test_grapheme_clusters_have_equal_length_but_still_differ
    gc_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).grapheme_clusters
    gc_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).grapheme_clusters

    assert_equal gc_nfc.size, gc_nfd.size
    refute_equal gc_nfc, gc_nfd
  end

  def test_grapheme_clusters_sdiff_reports_aligned_substitutions
    gc_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).grapheme_clusters
    gc_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).grapheme_clusters

    result = sdiff(gc_nfc, gc_nfd)

    # Only the decomposable graphemes change, and each is a one-for-one "!".
    changed = result.select { |c| c.action == "!" }
    assert_equal NFC_NFD_DECOMPOSABLE.join, changed.map(&:old_element).join

    # Nothing is a stray insertion or deletion; combining marks never float free.
    assert_empty result.select { |c| c.action == "+" || c.action == "-" }
  end

  def test_grapheme_clusters_diff_patches_in_both_directions
    gc_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).grapheme_clusters
    gc_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).grapheme_clusters

    result = diff(gc_nfc, gc_nfd)

    assert_equal gc_nfd, patch(gc_nfc, result)
    assert_equal gc_nfc, patch(gc_nfd, result)
  end

  def test_grapheme_clusters_unified_diff_renders_substitution
    gc_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).grapheme_clusters
    gc_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).grapheme_clusters

    result = diff(gc_nfc, gc_nfd)
    hunk = hunk(gc_nfc, gc_nfd, result.first, 1, 0)

    # The precomposed "è" (U+00E8) and the decomposed "e" + U+0300 are distinct
    # single graphemes; the \u escapes keep the two lines visually distinct.
    expected = <<~DIFF.chomp
      @@ -1,3 +1,3 @@
       D
      -\u00e8
      +e\u0300
       s
    DIFF

    assert_equal expected, hunk.diff(:unified)
  end

  # Word diff with accented characters. A single decomposed character flips the entire
  # containing word to "changed", so the diff is coarser: whole accented words are deleted
  # and their NFD equivalents inserted, clustered into runs anchored by the unaccented
  # words. Words without decomposable characters ("un", "cætera", ...) match in both forms
  # and contribute nothing.
  def test_word_split_diff_replaces_whole_accented_words
    w_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).split(/\s+/)
    w_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).split(/\s+/)

    assert_equal w_nfc.size, w_nfd.size
    refute_equal w_nfc, w_nfd

    result = diff(w_nfc, w_nfd)

    # Each chunk deletes accented NFC words and inserts the NFD equivalents; the deleted
    # and inserted runs are equal once normalized to a common form.
    result.each do |chunk|
      deleted = chunk.select { |c| c.action == "-" }.map(&:element)
      inserted = chunk.select { |c| c.action == "+" }.map(&:element)

      refute_equal deleted, inserted
      assert_equal deleted.map { |w| w.unicode_normalize(:nfd) }, inserted
    end
  end

  def test_word_split_diff_patches_in_both_directions
    w_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).split(/\s+/)
    w_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).split(/\s+/)

    result = diff(w_nfc, w_nfd)

    assert_equal w_nfd, patch(w_nfc, result)
    assert_equal w_nfc, patch(w_nfd, result)
  end

  def test_word_split_unified_diff_renders_whole_word_replacement
    w_nfc = NFC_NFD_PANGRAM.unicode_normalize(:nfc).split(/\s+/)
    w_nfd = NFC_NFD_PANGRAM.unicode_normalize(:nfd).split(/\s+/)

    result = diff(w_nfc, w_nfd)
    hunk = hunk(w_nfc, w_nfd, result.first, 1, 0)

    # The leading run "Dès Noël où" is replaced wholesale with its NFD form. The
    # \u escapes keep the NFC "-" lines distinct from the NFD "+" lines.
    expected = <<~DIFF.chomp
      @@ -1,4 +1,4 @@
      -D\u00e8s
      -No\u00ebl
      -o\u00f9
      +De\u0300s
      +Noe\u0308l
      +ou\u0300
       un
    DIFF

    assert_equal expected, hunk.diff(:unified)
  end
end
