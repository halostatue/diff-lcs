# frozen_string_literal: true

class << Diff::LCS
  def callbacks_for(callbacks) # :nodoc:
    callbacks.new
  rescue
    callbacks
  end
  private :callbacks_for

  def diff_traversal(method, seq1, seq2, callbacks, &block)
    diffs =
      if method == :sdiff && Diff::LCS::SDiffCallbacks.equal?(callbacks)
        Diff::LCS::Internals.sdiff_changes(seq1, seq2)
      elsif method == :diff && Diff::LCS::DiffCallbacks.equal?(callbacks)
        Diff::LCS::Internals.diff_hunks(seq1, seq2)
      else
        callbacks = callbacks_for(callbacks)

        case method
        when :diff
          traverse_sequences(seq1, seq2, callbacks)
        when :sdiff
          traverse_balanced(seq1, seq2, callbacks)
        end

        callbacks.finish if callbacks.respond_to? :finish
        callbacks.diffs
      end

    if block
      diffs.map do |hunk|
        if hunk.is_a? Array
          hunk.map { block.call(_1) }
        else
          block.call(hunk)
        end
      end
    else
      diffs
    end
  end
  private :diff_traversal
end

module Diff::LCS::Internals # :nodoc:
  # Compute the longest common subsequence between the sequenced enumerable values `a` and
  # `b`. The result is an array whose contents is such that
  #
  # ```ruby
  # result = Diff::LCS::Internals.lcs(a, b)
  # result.each_with_index do |e, i|
  #   assert_equal(a[i], b[e]) unless e.nil?
  # end
  # ```
  def self.lcs(a, b)
    a = indexable(a)
    b = indexable(b)
    a_start = b_start = 0
    a_finish = a.size - 1
    b_finish = b.size - 1
    vector = []

    # Collect any common elements at the beginning...
    while (a_start <= a_finish) && (b_start <= b_finish) && (a[a_start] == b[b_start])
      vector[a_start] = b_start
      a_start += 1
      b_start += 1
    end

    # Now the end...
    while (a_start <= a_finish) && (b_start <= b_finish) && (a[a_finish] == b[b_finish])
      vector[a_finish] = b_finish
      a_finish -= 1
      b_finish -= 1
    end

    # Now, compute the equivalence classes of positions of elements. An explanation for
    # how this works: https://codeforces.com/topic/92191
    b_matches = position_hash(b, b_start..b_finish)

    thresh = []
    links = []

    i = a_start
    while i <= a_finish
      bm = b_matches[a[i]]

      # Positions are visited in descending order, so each lands in a threshold slot no
      # higher than the previous one: `limit` bounds the search.
      limit = thresh.size - 1
      m = bm.size - 1

      while m >= 0
        j = bm[m]

        if thresh.empty? || (j > thresh[-1])
          k = thresh.size
        else
          # Find the first threshold not below `j`, galloping down from `limit`: positions
          # sharing an element tend to land in neighbouring slots. `j` replaces a larger
          # threshold; an equal one means `j` extends no subsequence.
          high = limit
          step = 1
          low = high - step
          while (low >= 0) && (thresh[low] >= j)
            high = low
            step *= 2
            low = high - step
          end
          low = low.negative? ? 0 : low + 1

          while low < high
            mid = (low + high) / 2
            if thresh[mid] < j
              low = mid + 1
            else
              high = mid
            end
          end

          if thresh[low] == j
            k = nil
            limit = low
          else
            k = low
          end
        end

        if k
          # The next positions down to the smallest one above the previous threshold all
          # land in this slot, each replacing the last: only that smallest one counts.
          lower = k.positive? ? thresh[k - 1] : -1
          if m.positive? && (bm[m - 1] > lower)
            m = bm.bsearch_index { _1 > lower }
            j = bm[m]
          end

          thresh[k] = j
          links[k] = [k.positive? ? links[k - 1] : nil, i, j]
          limit = k
        end

        m -= 1
      end

      i += 1
    end

    unless thresh.empty?
      link = links[thresh.size - 1]
      until link.nil?
        vector[link[1]] = link[2]
        link = link[0]
      end
    end

    vector
  end

  # Indexing a String allocates a new String on each access; its characters are read once
  # instead. Not for subclasses, whose `[]` may return more than a plain String
  # (`ActiveSupport::SafeBuffer` keeps slices HTML-safe).
  def self.indexable(seq) = seq.instance_of?(String) ? seq.chars : seq

  # Returns what `traverse_balanced` reports to `Diff::LCS::SDiffCallbacks`, built straight
  # from the LCS without an event to simplify per element. `TestDefaultCallbacksShortcut`
  # holds the two paths equal.
  def self.sdiff_changes(seq1, seq2)
    seq1 = indexable(seq1)
    seq2 = indexable(seq2)
    matches = lcs(seq1, seq2)
    changes = []
    a_i = b_j = m_a = 0

    loop do
      m_a += 1 while (m_a < matches.size) && matches[m_a].nil?

      # Past the last match, the ends of both sequences act as one.
      last = m_a >= matches.size
      m_b = last ? seq2.size : matches[m_a]
      m_a = seq1.size if last

      while (a_i < m_a) || (b_j < m_b)
        if (a_i < m_a) && (b_j < m_b)
          changes << Diff::LCS::ContextChange.new("!", a_i, seq1[a_i], b_j, seq2[b_j])
          a_i += 1
          b_j += 1
        elsif a_i < m_a
          changes << Diff::LCS::ContextChange.new("-", a_i, seq1[a_i], b_j, nil)
          a_i += 1
        else
          changes << Diff::LCS::ContextChange.new("+", a_i, nil, b_j, seq2[b_j])
          b_j += 1
        end
      end

      break if last

      changes << Diff::LCS::ContextChange.new("=", a_i, seq1[a_i], b_j, seq2[b_j])
      a_i += 1
      b_j += 1
      m_a += 1
    end

    changes
  end

  # Returns what `traverse_sequences` reports to `Diff::LCS::DiffCallbacks`, built straight
  # from the LCS without an event per element. `TestDefaultCallbacksShortcut` holds the two
  # paths equal.
  def self.diff_hunks(seq1, seq2)
    seq1 = indexable(seq1)
    seq2 = indexable(seq2)
    matches = lcs(seq1, seq2)
    a_size = seq1.size
    b_size = seq2.size
    hunks = []
    hunk = []
    a_i = b_j = 0

    matches.each do |b_line|
      if b_line.nil?
        hunk << Diff::LCS::Change.new("-", a_i, seq1[a_i]) unless seq1[a_i].nil?
      else
        while b_j < b_line
          hunk << Diff::LCS::Change.new("+", b_j, seq2[b_j])
          b_j += 1
        end

        unless hunk.empty?
          hunks << hunk
          hunk = []
        end
        b_j += 1
      end

      a_i += 1
    end

    # Not a copy of the tail loop of `traverse_sequences` but what it comes down to for
    # `DiffCallbacks`, which has neither `finished_a` nor `finished_b`: one discard of `a`
    # then one of `b` until both run out. A change to that loop must be carried over here.
    while (a_i < a_size) || (b_j < b_size)
      if a_i < a_size
        hunk << Diff::LCS::Change.new("-", a_i, seq1[a_i])
        a_i += 1
      end

      if b_j < b_size
        hunk << Diff::LCS::Change.new("+", b_j, seq2[b_j])
        b_j += 1
      end
    end

    hunks << hunk unless hunk.empty?
    hunks
  end

  # This method will analyze the provided patchset to provide a single-pass normalization
  # (conversion of the array form of Diff::LCS::Change objects to the object form of same)
  # and detection of whether the patchset represents changes to be made.
  def self.analyze_patchset(patchset, depth = 0)
    fail "Patchset too complex" if depth > 1

    has_changes = false
    new_patchset = []

    # Format:
    # [ # patchset
    #   # hunk (change)
    #   [ # hunk
    #     # change
    #   ]
    # ]

    patchset.each do |hunk|
      case hunk
      when Diff::LCS::Change, Diff::LCS::ContextChange
        has_changes ||= !hunk.unchanged?
        new_patchset << hunk
      when Array
        # Detect if the 'hunk' is actually an array-format change object.
        if Diff::LCS::Change.valid_action? hunk[0]
          hunk = Diff::LCS::Change.from_a(hunk)
          has_changes ||= !hunk.unchanged?
          new_patchset << hunk
        else
          with_changes, hunk = analyze_patchset(hunk, depth + 1)
          has_changes ||= with_changes
          new_patchset.concat(hunk)
        end
      else
        fail ArgumentError, "Cannot normalise a hunk of class #{hunk.class}."
      end
    end

    [has_changes, new_patchset]
  end

  # Examine the patchset and the source to see in which direction the patch should be
  # applied.
  #
  # WARNING: By default, this examines the whole patch, so this could take some time. This
  # also works better with Diff::LCS::ContextChange or Diff::LCS::Change as its source, as
  # an array will cause the creation of one of the above.
  def self.intuit_diff_direction(src, patchset, limit = nil)
    count = left_match = left_miss = right_match = right_miss = 0

    patchset.each do |change|
      count += 1

      case change
      when Diff::LCS::ContextChange
        le = src[change.old_position]
        re = src[change.new_position]

        case change.action
        when "-" # Remove details from the old string
          if le == change.old_element
            left_match += 1
          else
            left_miss += 1
          end
        when "+"
          if re == change.new_element
            right_match += 1
          else
            right_miss += 1
          end
        when "="
          left_miss += 1 if le != change.old_element
          right_miss += 1 if re != change.new_element
        when "!"
          if le == change.old_element
            left_match += 1
          elsif re == change.new_element
            right_match += 1
          else
            left_miss += 1
            right_miss += 1
          end
        end
      when Diff::LCS::Change
        # With a simplistic change, we can't tell the difference between the left and
        # right on '!' actions, so we ignore those. On '=' actions, if there's a miss, we
        # miss both left and right.
        element = src[change.position]

        case change.action
        when "-"
          if element == change.element
            left_match += 1
          else
            left_miss += 1
          end
        when "+"
          if element == change.element
            right_match += 1
          else
            right_miss += 1
          end
        when "="
          if element != change.element
            left_miss += 1
            right_miss += 1
          end
        end
      end

      break if !limit.nil? && (count > limit)
    end

    no_left = left_match.zero? && left_miss.positive?
    no_right = right_match.zero? && right_miss.positive?

    case [no_left, no_right]
    when [false, true]
      :patch
    when [true, false]
      :unpatch
    else
      case left_match <=> right_match
      when 1
        if left_miss.zero?
          :patch
        else
          :unpatch
        end
      when -1
        if right_miss.zero?
          :unpatch
        else
          :patch
        end
      else
        fail "The provided patchset does not appear to apply to the provided enumerable as either source or destination value."
      end
    end
  end

  class << self
    # If `vector` maps the matching elements of another collection onto this Enumerable,
    # compute the inverse of `vector` that maps this Enumerable onto the collection.
    # (Currently unused.)
    def inverse_vector(a, vector)
      inverse = a.dup
      (0...vector.size).each do
        inverse[vector[_1]] = i unless vector[_1].nil?
      end
      inverse
    end
    private :inverse_vector

    # Returns a hash mapping each element of an Enumerable to the set of positions it
    # occupies in the Enumerable, optionally restricted to the elements specified in the
    # range of indexes specified by `interval`.
    def position_hash(enum, interval)
      Hash.new { |h, k| h[k] = [] }.tap { |hash| interval.each { hash[enum[_1]] << _1 } }
    end
    private :position_hash
  end
end
