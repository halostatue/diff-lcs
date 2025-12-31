# frozen_string_literal: true

module Diff; end unless defined? Diff

# ## How Diff Works (by Mark-Jason Dominus)
#
# I once read an article written by the authors of `diff`; they said that they hard worked
# very hard on the algorithm until they found the right one.
#
# I think what they ended up using (and I hope someone will correct me, because I am not
# very confident about this) was the `longest common subsequence' method. In the LCS
# problem, you have two sequences of items:
#
# ```
# a b c d f g h j q z
# a b c d e f g i j k r x y z
# ```
#
# and you want to find the longest sequence of items that is present in both original
# sequences in the same order. That is, you want to find a new sequence *S* which can be
# obtained from the first sequence by deleting some items, and from the second sequence by
# deleting other items. You also want *S* to be as long as possible. In this case *S* is:
#
# ```
# a b c d f g j z
# ```
#
# From there it's only a small step to get diff-like output:
#
# ```
# e   h i   k   q r x y
# +   - +   +   - + + +
# ```
#
# This module solves the LCS problem. It also includes a canned function to generate
# `diff`-like output.
#
# It might seem from the example above that the LCS of two sequences is always pretty
# obvious, but that's not always the case, especially when the two sequences have many
# repeated elements. For example, consider
#
# ```
# a x b y c z p d q
# a b c a x b y c z
# ```
#
# A naive approach might start by matching up the `a` and `b` that appear at
# the beginning of each sequence, like this:
#
# ```
# a x b y c         z p d q
# a   b   c a b y c z
# ```
#
# This finds the common subsequence `a b c z`. But actually, the LCS is `a x b y c z`:
#
# ```
#       a x b y c z p d q
# a b c a x b y c z
# ```
module Diff::LCS
end

require "diff/lcs/version"
require "diff/lcs/callbacks"
require "diff/lcs/internals"

module Diff::LCS
  # Returns an Array containing the longest common subsequence(s) between `self` and
  # `other`. See Diff::LCS.lcs.
  def lcs(other, &block) = # :yields: self[i] if there are matched subsequences
    Diff::LCS.lcs(self, other, &block)

  # Returns the difference set between `self` and `other`. See Diff::LCS.diff.
  def diff(other, callbacks = nil, &block) = Diff::LCS.diff(self, other, callbacks, &block)

  # Returns the balanced ("side-by-side") difference set between `self` and `other`. See
  # Diff::LCS.sdiff.
  def sdiff(other, callbacks = nil, &block) = Diff::LCS.sdiff(self, other, callbacks, &block)

  # Traverses the discovered longest common subsequences between `self` and `other`. See
  # Diff::LCS.traverse_sequences.
  def traverse_sequences(other, callbacks = nil, &block) =
    Diff::LCS.traverse_sequences(self, other, callbacks || Diff::LCS::SequenceCallbacks, &block)

  # Traverses the discovered longest common subsequences between `self` and `other` using
  # the alternate, balanced algorithm. See Diff::LCS.traverse_balanced.
  def traverse_balanced(other, callbacks = nil, &block) =
    Diff::LCS.traverse_balanced(self, other, callbacks || Diff::LCS::BalancedCallbacks, &block)

  # Attempts to patch `self` with the provided `patchset`. A new sequence based on `self`
  # and the `patchset` will be created. See Diff::LCS.patch. Attempts to autodiscover the
  # direction of the patch.
  def patch(patchset) = Diff::LCS.patch(self, patchset)
  alias_method :unpatch, :patch

  # Attempts to patch `self` with the provided `patchset`. A new sequence based on `self`
  # and the `patchset` will be created. See Diff::LCS.patch!. Does no patch direction
  # autodiscovery.
  def patch!(patchset) = Diff::LCS.patch!(self, patchset)

  # Attempts to unpatch `self` with the provided `patchset`. A new sequence based on
  # `self` and the `patchset` will be created. See Diff::LCS.unpatch!. Does no patch
  # direction autodiscovery.
  def unpatch!(patchset) = Diff::LCS.unpatch!(self, patchset)

  # Attempts to patch `self` with the provided `patchset`, using #patch!. If the sequence
  # this is used on supports #replace, the value of `self` will be replaced. See
  # Diff::LCS.patch!. Does no patch direction autodiscovery.
  def patch_me(patchset)
    if respond_to? :replace
      replace(patch!(patchset))
    else
      patch!(patchset)
    end
  end

  # Attempts to unpatch `self` with the provided `patchset`, using #unpatch!. If the
  # sequence this is used on supports #replace, the value of `self` will be replaced. See
  # Diff::LCS#unpatch. Does no patch direction autodiscovery.
  def unpatch_me(patchset)
    if respond_to? :replace
      replace(unpatch!(patchset))
    else
      unpatch!(patchset)
    end
  end

  # Returns an Array containing the longest common subsequence(s) between `seq` and
  # `seq2`.
  #
  # > NOTE on comparing objects: Diff::LCS only works properly when each object can be
  # > used as a key in a Hash. This means that those objects must implement the methods
  # > `#hash` and `#eql?` such that two objects containing identical values compare
  # > identically for key purposes. That is:
  # >
  # > ```
  # > O.new('a').eql?(O.new('a')) == true && O.new('a').hash == O.new('a').hash
  # > ```
  def self.lcs(seq1, seq2, &block) # :yields: seq1[i] for each matched
    matches = Diff::LCS::Internals.lcs(seq1, seq2)
    [].tap { |result|
      matches.each_index do
        next if matches[_1].nil?

        v = seq1[_1]
        v = block.call(v) if block

        result << v
      end
    }
  end

  # `diff` computes the smallest set of additions and deletions necessary to turn the
  # first sequence into the second, and returns a description of these changes.
  #
  # See Diff::LCS::DiffCallbacks for the default behaviour. An alternate behaviour may be
  # implemented with Diff::LCS::ContextDiffCallbacks. If the `callbacks` object responds
  # to #finish, it will be called.
  def self.diff(seq1, seq2, callbacks = nil, &block) = # :yields: diff changes
    diff_traversal(:diff, seq1, seq2, callbacks || Diff::LCS::DiffCallbacks, &block)

  # `sdiff` computes all necessary components to show two sequences and their minimized
  # differences side by side, just like the Unix utility _sdiff_ does:
  #
  #
  # ```
  # old        <     -
  # same             same
  # before     |     after
  # -          >     new
  # ```
  #
  # See Diff::LCS::SDiffCallbacks for the default behaviour. An alternate behaviour may be
  # implemented with Diff::LCS::ContextDiffCallbacks. If the `callbacks` object responds
  # to #finish, it will be called.
  #
  # Each element of a returned array is a Diff::LCS::ContextChange object, which can be
  # implicitly converted to an array.
  #
  # ```ruby
  # Diff::LCS.sdiff(a, b).each do |action, (old_pos, old_element), (new_pos, new_element)|
  #   case action
  #   when '!'
  #     # replace
  #   when '-'
  #     # delete
  #   when '+'
  #     # insert
  #   end
  # end
  # ```
  def self.sdiff(seq1, seq2, callbacks = nil, &block) = # :yields: diff changes
    diff_traversal(:sdiff, seq1, seq2, callbacks || Diff::LCS::SDiffCallbacks, &block)

  # #traverse_sequences is the most general facility provided by this module; #diff and
  # #lcs are implemented using #traverse_sequences.
  #
  # The arguments to #traverse_sequence are the two sequences to traverse, and a callback
  # object, like this:
  #
  # ```ruby
  # traverse_sequences(seq1, seq2, Diff::LCS::ContextDiffCallbacks)
  # ```
  #
  # ### Callback Methods
  #
  # - `callbacks#match`: Called when `a` and `b` are pointing to common elements in `A`
  #   and `B`.
  # - `callbacks#discard_a`: Called when `a` is pointing to an element not in `B`.
  # - `callbacks#discard_b`: Called when `b` is pointing to an element not in `A`.
  # - `callbacks#finished_a`: Called when `a` has reached the end of sequence `A`.
  #   Optional.
  # - `callbacks#finished_b`: Called when `b` has reached the end of sequence `B`.
  #   Optional.
  #
  # ### Algorithm
  #
  # ```
  # a---+
  #     v
  # A = a b c e h j l m n p
  # B = b c d e f j k l m r s t
  #     ^
  # b---+
  # ```
  #
  # If there are two arrows (`a` and `b`) pointing to elements of sequences `A` and `B`,
  # the arrows will initially point to the first elements of their respective sequences.
  # #traverse_sequences will advance the arrows through the sequences one element at
  # a time, calling a method on the user-specified callback object before each advance. It
  # will advance the arrows in such a way that if there are elements `A[i]` and `B[j]`
  # which are both equal and part of the longest common subsequence, there will be some
  # moment during the execution of #traverse_sequences when arrow `a` is pointing to
  # `A[i]` and arrow `b` is pointing to `B[j]`. When this happens, #traverse_sequences
  # will call `callbacks#match` and then it will advance both arrows.
  #
  # Otherwise, one of the arrows is pointing to an element of its sequence that is not
  # part of the longest common subsequence. #traverse_sequences will advance that arrow
  # and will call `callbacks#discard_a` or `callbacks#discard_b`, depending on which arrow
  # it advanced. If both arrows point to elements that are not part of the longest common
  # subsequence, then #traverse_sequences will advance arrow `a` and call the appropriate
  # callback, then it will advance arrow `b` and call the appropriate callback.
  #
  # The methods for `callbacks#match`, `callbacks#discard_a`, and `callbacks#discard_b`
  # are invoked with an event comprising the action ("=", "+", or "-", respectively), the
  # indexes `i` and `j`, and the elements `A[i]` and `B[j]`. Return values are discarded
  # by #traverse_sequences.
  #
  # #### End of Sequences
  #
  # If arrow `a` reaches the end of its sequence before arrow `b` does, #traverse_sequence
  # will try to call `callbacks#finished_a` with the last index and element of `A`
  # (`A[-1]`) and the current index and element of `B` (`B[j]`). If `callbacks#finished_a`
  # does not exist, then `callbacks#discard_b` will be called on each element of `B` until
  # the end of the sequence is reached (the call will be done with `A[-1]` and `B[j]` for
  # each element).
  #
  # If `b` reaches the end of `B` before `a` reaches the end of `A`,
  # `callbacks#finished_b` will be called with the current index and element of `A`
  # (`A[i]`) and the last index and element of `B` (`A[-1]`). Again, if
  # `callbacks#finished_b` does not exist on the callback object, then
  # `callbacks#discard_a` will be called on each element of `A` until the end of the
  # sequence is reached (`A[i]` and `B[-1]`).
  #
  # There is a chance that one additional `callbacks#discard_a` or `callbacks#discard_b`
  # will be called after the end of the sequence is reached, if `a` has not yet reached
  # the end of `A` or `b` has not yet reached the end of `B`.
  def self.traverse_sequences(seq1, seq2, callbacks = nil) # :yields: change events
    callbacks ||= Diff::LCS::SequenceCallbacks
    matches = Diff::LCS::Internals.lcs(seq1, seq2)

    run_finished_a = run_finished_b = false

    a_size = seq1.size
    b_size = seq2.size
    a_i = b_j = 0

    matches.each do |b_line|
      if b_line.nil?
        unless seq1[a_i].nil?
          a_x = seq1[a_i]
          b_x = seq2[b_j]

          event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.discard_a(event)
        end
      else
        a_x = seq1[a_i]

        loop do
          break unless b_j < b_line

          b_x = seq2[b_j]
          event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.discard_b(event)
          b_j += 1
        end
        b_x = seq2[b_j]
        event = Diff::LCS::ContextChange.new("=", a_i, a_x, b_j, b_x)
        event = yield event if block_given?
        callbacks.match(event)
        b_j += 1
      end

      a_i += 1
    end

    # The last entry (if any) processed was a match. `a_i` and `b_j` point just past the
    # last matching lines in their sequences.
    while (a_i < a_size) || (b_j < b_size)
      # last A?
      if a_i == a_size && b_j < b_size
        if callbacks.respond_to?(:finished_a) && !run_finished_a
          a_x = seq1[-1]
          b_x = seq2[b_j]
          event = Diff::LCS::ContextChange.new(">", a_size - 1, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.finished_a(event)
          run_finished_a = true
        else
          a_x = seq1[a_i]
          loop do
            b_x = seq2[b_j]
            event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
            event = yield event if block_given?
            callbacks.discard_b(event)
            b_j += 1
            break unless b_j < b_size
          end
        end
      end

      # last B?
      if b_j == b_size && a_i < a_size
        if callbacks.respond_to?(:finished_b) && !run_finished_b
          a_x = seq1[a_i]
          b_x = seq2[-1]
          event = Diff::LCS::ContextChange.new("<", a_i, a_x, b_size - 1, b_x)
          event = yield event if block_given?
          callbacks.finished_b(event)
          run_finished_b = true
        else
          b_x = seq2[b_j]
          loop do
            a_x = seq1[a_i]
            event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
            event = yield event if block_given?
            callbacks.discard_a(event)
            a_i += 1
            break unless b_j < b_size
          end
        end
      end

      if a_i < a_size
        a_x = seq1[a_i]
        b_x = seq2[b_j]
        event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
        event = yield event if block_given?
        callbacks.discard_a(event)
        a_i += 1
      end

      if b_j < b_size
        a_x = seq1[a_i]
        b_x = seq2[b_j]
        event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
        event = yield event if block_given?
        callbacks.discard_b(event)
        b_j += 1
      end
    end
  end

  # #traverse_balanced is an alternative to #traverse_sequences. It uses a different
  # algorithm to iterate through the entries in the computed longest common subsequence.
  # Instead of viewing the changes as insertions or deletions from one of the sequences,
  # #traverse_balanced will report _changes_ between the sequences.
  #
  # The arguments to #traverse_balanced are the two sequences to traverse and a callback
  # object, like this:
  #
  # ```ruby
  # traverse_balanced(seq1, seq2, Diff::LCS::ContextDiffCallbacks)
  # ```
  #
  # #sdiff is implemented using #traverse_balanced.
  #
  # ### Callback Methods
  #
  # - `callbacks#match`: Called when `a` and `b` are pointing to common elements in `A`
  #   and `B`.
  # - `callbacks#discard_a`: Called when `a` is pointing to an element not in `B`.
  # - `callbacks#discard_b`: Called when `b` is pointing to an element not in `A`.
  # - `callbacks#change`: Called when `a` and `b` are pointing to the same relative
  #   position, but `A[a]` and `B[b]` are not the same; a _change_ has occurred. Optional.
  #
  # #traverse_balanced might be a bit slower than #traverse_sequences, noticeable only
  # while processing large amounts of data.
  #
  # ### Algorithm
  #
  # ```
  # a---+
  #     v
  # A = a b c e h j l m n p
  # B = b c d e f j k l m r s t
  #     ^
  # b---+
  # ```
  #
  # #### Matches
  #
  # If there are two arrows (`a` and `b`) pointing to elements of sequences `A` and `B`,
  # the arrows will initially point to the first elements of their respective sequences.
  # #traverse_sequences will advance the arrows through the sequences one element at
  # a time, calling a method on the user-specified callback object before each advance. It
  # will advance the arrows in such a way that if there are elements `A[i]` and
  # `B[j]` which are both equal and part of the longest common subsequence, there will be
  # some moment during the execution of #traverse_sequences when arrow `a` is pointing to
  # `A[i]` and arrow `b` is pointing to `B[j]`. When this happens, #traverse_sequences
  # will call `callbacks#match` and then it will advance both arrows.
  #
  # #### Discards
  #
  # Otherwise, one of the arrows is pointing to an element of its sequence that is not
  # part of the longest common subsequence. #traverse_sequences will advance that arrow
  # and will call `callbacks#discard_a` or `callbacks#discard_b`, depending on which arrow
  # it advanced.
  #
  # #### Changes
  #
  # If both `a` and `b` point to elements that are not part of the longest common
  # subsequence, then #traverse_sequences will try to call `callbacks#change` and advance
  # both arrows. If `callbacks#change` is not implemented, then `callbacks#discard_a` and
  # `callbacks#discard_b` will be called in turn.
  #
  # The methods for `callbacks#match`, `callbacks#discard_a`, `callbacks#discard_b`, and
  # `callbacks#change` are invoked with an event comprising the action ("=", "+", "-", or
  # "!", respectively), the indexes `i` and `j`, and the elements `A[i]` and `B[j]`.
  # Return values are discarded by #traverse_balanced.
  #
  # === Context
  #
  # Note that `i` and `j` may not be the same index position, even if `a` and `b` are
  # considered to be pointing to matching or changed elements.
  def self.traverse_balanced(seq1, seq2, callbacks = Diff::LCS::BalancedCallbacks)
    matches = Diff::LCS::Internals.lcs(seq1, seq2)
    a_size = seq1.size
    b_size = seq2.size
    a_i = b_j = m_b = 0
    m_a = -1

    # Process all the lines in the match vector.
    loop do
      # Find next match indexes `m_a` and `m_b`
      loop do
        m_a += 1
        break unless m_a < matches.size && matches[m_a].nil?
      end

      break if m_a >= matches.size # end of matches?

      m_b = matches[m_a]

      # Change(seq2)
      while (a_i < m_a) || (b_j < m_b)
        a_x = seq1[a_i]
        b_x = seq2[b_j]

        case [(a_i < m_a), (b_j < m_b)]
        when [true, true]
          if callbacks.respond_to?(:change)
            event = Diff::LCS::ContextChange.new("!", a_i, a_x, b_j, b_x)
            event = yield event if block_given?
            callbacks.change(event)
            a_i += 1
          else
            event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
            event = yield event if block_given?
            callbacks.discard_a(event)
            a_i += 1
            a_x = seq1[a_i]
            event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
            event = yield event if block_given?
            callbacks.discard_b(event)
          end

          b_j += 1
        when [true, false]
          event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.discard_a(event)
          a_i += 1
        when [false, true]
          event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.discard_b(event)
          b_j += 1
        end
      end

      # Match
      a_x = seq1[a_i]
      b_x = seq2[b_j]
      event = Diff::LCS::ContextChange.new("=", a_i, a_x, b_j, b_x)
      event = yield event if block_given?
      callbacks.match(event)
      a_i += 1
      b_j += 1
    end

    while (a_i < a_size) || (b_j < b_size)
      a_x = seq1[a_i]
      b_x = seq2[b_j]

      case [(a_i < a_size), (b_j < b_size)]
      when [true, true]
        if callbacks.respond_to?(:change)
          event = Diff::LCS::ContextChange.new("!", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.change(event)
          a_i += 1
        else
          event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.discard_a(event)
          a_i += 1
          a_x = seq1[a_i]
          event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
          event = yield event if block_given?
          callbacks.discard_b(event)
        end

        b_j += 1
      when [true, false]
        event = Diff::LCS::ContextChange.new("-", a_i, a_x, b_j, b_x)
        event = yield event if block_given?
        callbacks.discard_a(event)
        a_i += 1
      when [false, true]
        event = Diff::LCS::ContextChange.new("+", a_i, a_x, b_j, b_x)
        event = yield event if block_given?
        callbacks.discard_b(event)
        b_j += 1
      end
    end
  end

  # standard:disable Style/HashSyntax
  PATCH_MAP = { # :nodoc:
    :patch => {"+" => "+", "-" => "-", "!" => "!", "=" => "="}.freeze,
    :unpatch => {"+" => "-", "-" => "+", "!" => "!", "=" => "="}.freeze
  }.freeze
  private_constant :PATCH_MAP
  # standard:enable Style/HashSyntax

  # Applies a `patchset` to the sequence `src` according to the `direction` (`:patch` or
  # `:unpatch`), producing a new sequence.
  #
  # If the `direction` is not specified, Diff::LCS::patch will attempt to discover the
  # direction of the `patchset`.
  #
  # A `patchset` can be considered to apply forward (`:patch`) if the following expression
  # is true:
  #
  # ```ruby
  # patch(s1, diff(s1, s2)) # => s2
  # ```
  #
  # A `patchset` can be considered to apply backward (`:unpatch`) if the following
  # expression is true:
  #
  # ```ruby
  # patch(s2, diff(s1, s2)) # => s1
  # ```
  #
  # If the `patchset` contains no changes, the `src` value will be returned as either
  # `src.dup` or `src`. A `patchset` can be deemed as having no changes if the following
  # predicate returns true:
  #
  # ```ruby
  # patchset.empty? or patchset.flatten(1).all? { |change| change.unchanged? }
  # ```
  #
  # ### Patchsets
  #
  # A `patchset` is always an enumerable sequence of changes, hunks of changes, or a mix
  # of the two. A hunk of changes is an enumerable sequence of changes:
  #
  # ```
  # [ # patchset
  #   # change
  #   [ # hunk
  #     # change
  #   ]
  # ]
  # ```
  #
  # The `patch` method accepts `patchset`s that are enumerable sequences containing either
  # Diff::LCS::Change objects (or a subclass) or the array representations of those
  # objects. Prior to application, array representations of Diff::LCS::Change objects will
  # be reified.
  def self.patch(src, patchset, direction = nil)
    # Normalize the patchset.
    has_changes, patchset = Diff::LCS::Internals.analyze_patchset(patchset)

    return src.respond_to?(:dup) ? src.dup : src unless has_changes

    # Start with a new empty type of the source's class
    res = src.class.new

    direction ||= Diff::LCS::Internals.intuit_diff_direction(src, patchset)

    a_i = b_j = 0

    patch_map = PATCH_MAP[direction]

    patchset.each do |change|
      # Both Change and ContextChange support #action
      action = patch_map[change.action]

      case change
      when Diff::LCS::ContextChange
        case direction
        when :patch
          el = change.new_element
          op = change.old_position
          np = change.new_position
        when :unpatch
          el = change.old_element
          op = change.new_position
          np = change.old_position
        end

        case action
        when "-" # Remove details from the old string
          while a_i < op
            res << src[a_i]
            a_i += 1
            b_j += 1
          end
          a_i += 1
        when "+"
          while b_j < np
            res << src[a_i]
            a_i += 1
            b_j += 1
          end

          res << el
          b_j += 1
        when "="
          # This only appears in sdiff output with the SDiff callback.
          # Therefore, we only need to worry about dealing with a single
          # element.
          res << el

          a_i += 1
          b_j += 1
        when "!"
          while a_i < op
            res << src[a_i]
            a_i += 1
            b_j += 1
          end

          b_j += 1
          a_i += 1

          res << el
        end
      when Diff::LCS::Change
        case action
        when "-"
          while a_i < change.position
            res << src[a_i]
            a_i += 1
            b_j += 1
          end
          a_i += 1
        when "+"
          while b_j < change.position
            res << src[a_i]
            a_i += 1
            b_j += 1
          end

          b_j += 1

          res << change.element
        end
      end
    end

    while a_i < src.size
      res << src[a_i]
      a_i += 1
      b_j += 1
    end

    res
  end

  # Given a patchset, convert the current version to the prior version. Does no
  # auto-discovery.
  def self.unpatch!(src, patchset) = patch(src, patchset, :unpatch)

  # Given a patchset, convert the current version to the next version. Does no
  # auto-discovery.
  def self.patch!(src, patchset) = patch(src, patchset, :patch)
end
