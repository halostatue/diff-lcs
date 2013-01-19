# -*- ruby encoding: utf-8 -*-

module Diff::LCS::Internals # :nodoc:
  class << self
    # Compute the longest common subsequence between the sequenced
    # Enumerables +a+ and +b+. The result is an array whose contents is such
    # that
    #
    #     result = Diff::LCS::Internals.lcs(a, b)
    #     result.each_with_index do |e, ii|
    #       assert_equal(a[ii], b[e]) unless e.nil?
    #     end
    def lcs(a, b)
      a_start = b_start = 0
      a_finish = a.size - 1
      b_finish = b.size - 1
      vector = []

      # Prune off any common elements at the beginning...
      while (a_start <= a_finish) and
        (b_start <= b_finish) and
        (a[a_start] == b[b_start])
        vector[a_start] = b_start
        a_start += 1
        b_start += 1
      end

      # Now the end...
      while (a_start <= a_finish) and
        (b_start <= b_finish) and
        (a[a_finish] == b[b_finish])
        vector[a_finish] = b_finish
        a_finish -= 1
        b_finish -= 1
      end

      # Now, compute the equivalence classes of positions of elements.
      b_matches = position_hash(b, b_start .. b_finish)

      thresh = []
      links = []

      (a_start .. a_finish).each do |ii|
        ai = a.kind_of?(String) ? a[ii, 1] : a[ii]
        bm = b_matches[ai]
        kk = nil
        bm.reverse_each do |jj|
          if kk and (thresh[kk] > jj) and (thresh[kk - 1] < jj)
            thresh[kk] = jj
          else
            kk = replace_next_larger(thresh, jj, kk)
          end
          links[kk] = [ (kk > 0) ? links[kk - 1] : nil, ii, jj ] unless kk.nil?
        end
      end

      unless thresh.empty?
        link = links[thresh.size - 1]
        while not link.nil?
          vector[link[1]] = link[2]
          link = link[0]
        end
      end

      vector
    end

    # This method will analyze the provided patchset to provide a
    # single-pass normalization (conversion of the array form of
    # Diff::LCS::Change objects to the object form of same) and detection of
    # whether the patchset represents changes to be made.
    def analyze_patchset(patchset, depth = 0)
      raise "Patchset too complex" if depth > 1

      has_changes = false

      # Format:
      # [ # patchset
      #   # hunk (change)
      #   [ # hunk
      #     # change
      #   ]
      # ]

      patchset = patchset.map do |hunk|
        case hunk
        when Diff::LCS::Change
          has_changes ||= !hunk.unchanged?
          hunk
        when Array
          # Detect if the 'hunk' is actually an array-format
          # Change object.
          if Diff::LCS::Change.valid_action? hunk[0]
            hunk = Diff::LCS::Change.from_a(hunk)
            has_changes ||= !hunk.unchanged?
            hunk
          else
            with_changes, hunk = analyze_patchset(hunk, depth + 1)
            has_changes ||= with_changes
            hunk
          end
        else
          raise ArgumentError, "Cannot normalise a hunk of class #{hunk.class}."
        end
      end

      [ has_changes, patchset ]
    end

    # Find the place at which +value+ would normally be inserted into the
    # Enumerable. If that place is already occupied by +value+, do nothing
    # and return +nil+. If the place does not exist (i.e., it is off the end
    # of the Enumerable), add it to the end. Otherwise, replace the element
    # at that point with +value+. It is assumed that the Enumerable's values
    # are numeric.
    #
    # This operation preserves the sort order.
    def replace_next_larger(enum, value, last_index = nil)
        # Off the end?
      if enum.empty? or (value > enum[-1])
        enum << value
        return enum.size - 1
      end

        # Binary search for the insertion point
      last_index ||= enum.size
      first_index = 0
      while (first_index <= last_index)
        ii = (first_index + last_index) >> 1

        found = enum[ii]

        if value == found
          return nil
        elsif value > found
          first_index = ii + 1
        else
          last_index = ii - 1
        end
      end

        # The insertion point is in first_index; overwrite the next larger
        # value.
      enum[first_index] = value
      return first_index
    end

    # If +vector+ maps the matching elements of another collection onto this
    # Enumerable, compute the inverse +vector+ that maps this Enumerable
    # onto the collection. (Currently unused.)
    def inverse_vector(a, vector)
      inverse = a.dup
      (0 ... vector.size).each do |ii|
        inverse[vector[ii]] = ii unless vector[ii].nil?
      end
      inverse
    end

    # Returns a hash mapping each element of an Enumerable to the set of
    # positions it occupies in the Enumerable, optionally restricted to the
    # elements specified in the range of indexes specified by +interval+.
    def position_hash(enum, interval = 0 .. -1)
      hash = Hash.new { |hh, kk| hh[kk] = [] }
      interval.each do |ii|
        kk = enum.kind_of?(String) ? enum[ii, 1] : enum[ii]
        hash[kk] << ii
      end
      hash
    end

    # Examine the patchset and the source to see in which direction the
    # patch should be applied.
    #
    # WARNING: By default, this examines the whole patch, so this could take
    # some time. This also works better with Diff::LCS::ContextChange or
    # Diff::LCS::Change as its source, as an array will cause the creation
    # of one of the above.
    #
    # Note: This will be deprecated as a public function in a future release.
    def diff_direction(src, patchset, limit = nil)
      count = left_match = left_miss = right_match = right_miss = 0
      string = src.kind_of?(String)

      patchset.each do |change|
        count += 1

        case change
        when Diff::LCS::ContextChange
          case change.action
          when '-' # Remove details from the old string
            element = string ? src[change.old_position, 1] : src[change.old_position]

            if element == change.old_element
              left_match += 1
            else
              left_miss += 1
            end
          when '+'
            element = string ? src[change.new_position, 1] : src[change.new_position]
            if element == change.new_element
              right_match += 1
            else
              right_miss += 1
            end
          when '='
            le = string ? src[change.old_position, 1] : src[change.old_position]
            re = string ? src[change.new_position, 1] : src[change.new_position]

            left_miss += 1 if le != change.old_element
            right_miss += 1 if re != change.new_element
          when '!'
            element = string ? src[change.old_position, 1] : src[change.old_position]
            if element == change.old_element
              left_match += 1
            else
              element = string ? src[change.new_position, 1] : src[change.new_position]
              if element == change.new_element
                right_match += 1
              else
                left_miss += 1
                right_miss += 1
              end
            end
          end
        when Diff::LCS::Change
          # With a simplistic change, we can't tell the difference between
          # the left and right on '!' actions, so we ignore those. On '='
          # actions, if there's a miss, we miss both left and right.
          element = string ? src[change.position, 1] : src[change.position]

          case change.action
          when '-'
            if element == change.element
              left_match += 1
            else
              left_miss += 1
            end
          when '+'
            if element == change.element
              right_match += 1
            else
              right_miss += 1
            end
          when '='
            if element != change.element
              left_miss += 1
              right_miss += 1
            end
          end
        end

        break if (not limit.nil?) && (count > limit)
      end

      if left_match.zero?
      end

      no_left = (left_match == 0) && (left_miss >= 0)
      no_right = (right_match == 0) && (right_miss >= 0)

      case [no_left, no_right]
      when [false, true]
        :patch
      when [true, false]
        :unpatch
      else
        raise "The provided patchset does not appear to apply to the provided value as either source or destination value."
      end
    end
  end
end
