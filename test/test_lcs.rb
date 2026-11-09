# frozen_string_literal: true

require_relative "test_helper"

class TestLCSInternals < Minitest::Test
  def test_returns_meaningful_lcs_array_with_seq1_seq2
    res = internal_lcs(seq1, seq2)
    assert_equal correct_lcs.size, res.compact.size
    assert_correctly_maps_sequence(res, seq1, seq2)

    x_seq1 = (0...res.size).map { |ix| res[ix] ? seq1[ix] : nil }.compact
    x_seq2 = (0...res.size).map { |ix| res[ix] ? seq2[res[ix]] : nil }.compact

    assert_equal correct_lcs, x_seq1
    assert_equal correct_lcs, x_seq2
  end

  def test_returns_all_indexes_with_hello_hello
    assert_equal (0...hello.size).to_a, internal_lcs(hello, hello)
  end

  def test_returns_all_indexes_with_hello_ary_hello_ary
    assert_equal (0...hello_ary.size).to_a, internal_lcs(hello_ary, hello_ary)
  end

  def test_maps_strings_like_their_characters
    assert_equal internal_lcs("abcabba", "cbabac"), internal_lcs("abcabba".chars, "cbabac".chars)
  end

  def test_finds_a_longest_common_subsequence_among_repeated_elements
    random = Random.new(20261103)

    500.times do
      alphabet_size = [1, 2, 3, 5].sample(random:)
      s1 = Array.new(random.rand(0..30)) { random.rand(alphabet_size) }
      s2 = Array.new(random.rand(0..30)) { random.rand(alphabet_size) }
      assert_longest_common_subsequence(s1, s2)
    end
  end

  def test_finds_longest_common_subsequences_in_a_larger_corpus
    random = Random.new(20261108)

    [0..100, 200..300, 400..500].each do |length_range|
      20.times do
        alphabet_size = random.rand(2..50)
        s1 = Array.new(random.rand(length_range)) { random.rand(alphabet_size) }
        s2 = Array.new(random.rand(length_range)) { random.rand(alphabet_size) }
        assert_longest_common_subsequence(s1, s2)
      end
    end
  end

  private def assert_longest_common_subsequence(s1, s2)
    res = internal_lcs(s1, s2)

    assert_correctly_maps_sequence(res, s1, s2)
    assert_equal res.compact, res.compact.sort.uniq
    assert_equal dynamic_programming_lcs_size(s1, s2), res.compact.size
    assert_equal reference_lcs(s1, s2), res, "picked another LCS for #{s1.inspect} / #{s2.inspect}"
  end

  # Hunt-Szymanski as diff-lcs 2.0.0 runs it, without the shortcuts of `Internals.lcs`:
  # among several longest common subsequences, the one both must return.
  private def reference_lcs(a, b)
    a_start = b_start = 0
    a_finish = a.size - 1
    b_finish = b.size - 1
    vector = []

    while (a_start <= a_finish) && (b_start <= b_finish) && (a[a_start] == b[b_start])
      vector[a_start] = b_start
      a_start += 1
      b_start += 1
    end

    while (a_start <= a_finish) && (b_start <= b_finish) && (a[a_finish] == b[b_finish])
      vector[a_finish] = b_finish
      a_finish -= 1
      b_finish -= 1
    end

    b_matches = Hash.new { |h, k| h[k] = [] }
    (b_start..b_finish).each { b_matches[b[_1]] << _1 }
    thresh = []
    links = []

    (a_start..a_finish).each do |i|
      b_matches[a[i]].reverse_each do |j|
        k = thresh.bsearch_index { _1 >= j } || thresh.size
        next if thresh[k] == j

        thresh[k] = j
        links[k] = [k.positive? ? links[k - 1] : nil, i, j]
      end
    end

    link = links[thresh.size - 1]
    until link.nil?
      vector[link[1]] = link[2]
      link = link[0]
    end
    vector
  end

  private def dynamic_programming_lcs_size(s1, s2)
    previous_row = Array.new(s2.size + 1, 0)
    s1.each do |element|
      row = [0]
      s2.each_with_index do |other, index|
        row << ((element == other) ? previous_row[index] + 1 : [previous_row[index + 1], row[index]].max)
      end
      previous_row = row
    end
    previous_row.last
  end
end

# `diff` and `sdiff` with their default callbacks skip the traversals and build their
# results straight from the LCS; a callbacks instance still goes through the traversals.
class TestDefaultCallbacksShortcut < Minitest::Test
  def test_diff_matches_traverse_sequences_with_diff_callbacks
    each_random_pair do |s1, s2|
      assert_equal diff(s1, s2, Diff::LCS::DiffCallbacks.new), diff(s1, s2),
        "diff drifted from traverse_sequences for #{s1.inspect} / #{s2.inspect}"
    end
  end

  def test_sdiff_matches_traverse_balanced_with_sdiff_callbacks
    each_random_pair do |s1, s2|
      assert_equal sdiff(s1, s2, Diff::LCS::SDiffCallbacks.new), sdiff(s1, s2),
        "sdiff drifted from traverse_balanced for #{s1.inspect} / #{s2.inspect}"
    end
  end

  def test_never_compares_callbacks_with_double_equals
    callbacks = Class.new {
      undef_method :==

      def match(_event) = nil

      def diffs = :traversed
    }.new

    assert_equal :traversed, sdiff([1], [1], callbacks)
    assert_equal :traversed, diff([1], [1], callbacks)
  end

  def test_reads_string_subclasses_through_their_own_brackets
    tagged = Class.new(String) { def [](...) = self.class.new(super) }

    sdiff(tagged.new("ab"), tagged.new("ac")).each do |change|
      [change.old_element, change.new_element].compact.each { assert_instance_of tagged, _1 }
    end
  end

  private def each_random_pair
    random = Random.new(20261108)

    1000.times do
      alphabet = [nil, *0...random.rand(1..6)]
      s1 = Array.new(random.rand(0..25)) { alphabet.sample(random:) }
      s2 = Array.new(random.rand(0..25)) { alphabet.sample(random:) }
      yield s1, s2

      letters = "abcdef"[0, random.rand(1..6)].chars
      t1 = Array.new(random.rand(0..25)) { letters.sample(random:) }.join
      t2 = Array.new(random.rand(0..25)) { letters.sample(random:) }.join
      yield t1, t2
    end
  end
end

class TestLCS < Minitest::Test
  def test_returns_correct_compacted_values
    res = lcs(seq1, seq2)
    assert_equal correct_lcs, res
    assert_equal res, res.compact
  end

  def test_is_transitive
    res = lcs(seq2, seq1)
    assert_equal correct_lcs, res
    assert_equal res, res.compact
  end

  def test_returns_hello_chars_with_hello_hello
    assert_equal hello.chars, lcs(hello, hello)
  end

  def test_returns_hello_ary_with_hello_ary_hello_ary
    assert_equal hello_ary, lcs(hello_ary, hello_ary)
  end
end
