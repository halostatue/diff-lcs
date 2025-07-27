# frozen_string_literal: true

require "diff/lcs/change"

# This callback object implements the default set of callback events, which only returns
# the event itself.
#
# ```ruby
# Diff::LCS.lcs(seq1, seq2, Diff::LCS::DefaultCallbacks)
# ```
class Diff::LCS::DefaultCallbacks
  # Called when two items match.
  def self.match(event) = event

  # Called when the old value is discarded in favour of the new value.
  def self.discard_a(event) = event

  # Called when the new value is discarded in favour of the old value.
  def self.discard_b(event) = event

  # Called when both the old and new values have changed.
  def self.change(event) = event

  def self.new = self

  class << self
    private :new
  end
end

# An alias for DefaultCallbacks used in Diff::LCS.traverse_sequences.
#
# ```ruby
# Diff::LCS.lcs(seq1, seq2, Diff::LCS::SequenceCallbacks)
# ```
Diff::LCS::SequenceCallbacks = Diff::LCS::DefaultCallbacks

# An alias for DefaultCallbacks used in Diff::LCS.traverse_balanced.
#
# ```ruby
# Diff::LCS.lcs(seq1, seq2, Diff::LCS::BalancedCallbacks)
# ```
Diff::LCS::BalancedCallbacks = Diff::LCS::DefaultCallbacks

# This will produce a compound array of simple diff change objects. Each element in the
# #diffs array is a `hunk` or `hunk` array, where each element in each `hunk` array is
# a single Change object representing the addition or removal of a single element from one
# of the two tested sequences. The `hunk` provides the full context for the changes.
#
# ```ruby
# diffs = Diff::LCS.diff(seq1, seq2)
# # This example shows a simplified array format.
# # [ [ [ '-',  0, 'a' ] ],   # 1
# #   [ [ '+',  2, 'd' ] ],   # 2
# #   [ [ '-',  4, 'h' ],     # 3
# #     [ '+',  4, 'f' ] ],
# #   [ [ '+',  6, 'k' ] ],   # 4
# #   [ [ '-',  8, 'n' ],     # 5
# #     [ '-',  9, 'p' ],
# #     [ '+',  9, 'r' ],
# #     [ '+', 10, 's' ],
# #     [ '+', 11, 't' ] ] ]
# ```
#
# There are five hunks here. The first hunk says that the `a` at position 0 of the first
# sequence should be deleted (`'-'`). The second hunk says that the `d` at position 2 of
# the second sequence should be inserted (`'+'`). The third hunk says that the `h` at
# position 4 of the first sequence should be removed and replaced with the `f` from
# position 4 of the second sequence. The other two hunks are described similarly.
#
# ### Use
#
# This callback object must be initialised and is used by the Diff::LCS#diff method.
#
# ```ruby
# cbo = Diff::LCS::DiffCallbacks.new
# Diff::LCS.lcs(seq1, seq2, cbo)
# cbo.finish
# ```
#
# Note that the call to #finish is absolutely necessary, or the last set of changes will
# not be visible. This callback also supports a block mode which automatically calls
# #finish.
#
# ```ruby
# result = Diff::LCS::DiffCallbacks.new { |cbo| Diff::LCS.lcs(seq1, seq2, cbo) }
# ```
#
# ### Simplified Array Format
#
# The simplified array format used in the example above can be obtained with:
#
# ```ruby
# require 'pp'
# pp diffs.map { |e| e.map { |f| f.to_a } }
# ```
class Diff::LCS::DiffCallbacks
  # Returns the difference set collected during the diff process.
  attr_reader :diffs

  def initialize # :yields: self
    @hunk = []
    @diffs = []

    return unless block_given?

    begin
      yield self
    ensure
      finish
    end
  end

  # Finalizes the diff process. If an unprocessed hunk still exists, then it is appended
  # to the diff list.
  def finish = finish_hunk

  def match(_event) = finish_hunk

  def discard_a(event)
    @hunk << Diff::LCS::Change.new("-", event.old_position, event.old_element)
  end

  def discard_b(event)
    @hunk << Diff::LCS::Change.new("+", event.new_position, event.new_element)
  end

  def finish_hunk
    @diffs << @hunk unless @hunk.empty?
    @hunk = []
  end
  private :finish_hunk
end

# This will produce a compound array of contextual diff change objects. Each element in
# the #diffs array is a "hunk" array, where each element in each "hunk" array is a single
# change. Each change is a Diff::LCS::ContextChange that contains both the old index and
# new index values for the change. The "hunk" provides the full context for the changes.
# Both old and new objects will be presented for changed objects. `nil` will be
# substituted for a discarded object.
#
# ```ruby
# seq1 = %w(a b c e h j l m n p)
# seq2 = %w(b c d e f j k l m r s t)
#
# diffs = Diff::LCS.diff(seq1, seq2, Diff::LCS::ContextDiffCallbacks)
# # This example shows a simplified array format.
# # [ [ [ '-', [  0, 'a' ], [  0, nil ] ] ],   # 1
# #   [ [ '+', [  3, nil ], [  2, 'd' ] ] ],   # 2
# #   [ [ '-', [  4, 'h' ], [  4, nil ] ],     # 3
# #     [ '+', [  5, nil ], [  4, 'f' ] ] ],
# #   [ [ '+', [  6, nil ], [  6, 'k' ] ] ],   # 4
# #   [ [ '-', [  8, 'n' ], [  9, nil ] ],     # 5
# #     [ '+', [  9, nil ], [  9, 'r' ] ],
# #     [ '-', [  9, 'p' ], [ 10, nil ] ],
# #     [ '+', [ 10, nil ], [ 10, 's' ] ],
# #     [ '+', [ 10, nil ], [ 11, 't' ] ] ] ]
# ```
#
# The five hunks shown are comprised of individual changes; if there is a related set of
# changes, they are still shown individually.
#
# This callback can also be used with Diff::LCS#sdiff, which will produce results like:
#
# ```ruby
# diffs = Diff::LCS.sdiff(seq1, seq2, Diff::LCS::ContextCallbacks)
# # This example shows a simplified array format.
# # [ [ [ "-", [  0, "a" ], [  0, nil ] ] ],  # 1
# #   [ [ "+", [  3, nil ], [  2, "d" ] ] ],  # 2
# #   [ [ "!", [  4, "h" ], [  4, "f" ] ] ],  # 3
# #   [ [ "+", [  6, nil ], [  6, "k" ] ] ],  # 4
# #   [ [ "!", [  8, "n" ], [  9, "r" ] ],    # 5
# #     [ "!", [  9, "p" ], [ 10, "s" ] ],
# #     [ "+", [ 10, nil ], [ 11, "t" ] ] ] ]
# ```
#
# The five hunks are still present, but are significantly shorter in total presentation,
# because changed items are shown as changes ("!") instead of potentially "mismatched"
# pairs of additions and deletions.
#
# The result of this operation is similar to that of Diff::LCS::SDiffCallbacks. They may
# be compared as:
#
# ```ruby
# s = Diff::LCS.sdiff(seq1, seq2).reject { |e| e.action == "=" }
# c = Diff::LCS.sdiff(seq1, seq2, Diff::LCS::ContextDiffCallbacks).flatten(1)
#
# s == c # => true
# ```
#
# ### Use
#
# This callback object must be initialised and can be used by the Diff::LCS#diff or
# Diff::LCS#sdiff methods.
#
# ```ruby
# cbo = Diff::LCS::ContextDiffCallbacks.new
# Diff::LCS.lcs(seq1, seq2, cbo)
# cbo.finish
# ```
#
# Note that the call to #finish is absolutely necessary, or the last set of changes will
# not be visible. This callback also supports a block mode which automatically calls
# #finish.
#
# ```ruby
# result = Diff::LCS::ContextDiffCallbacks.new { |cbo| Diff::LCS.lcs(seq1, seq2, cbo) }
# ```
#
# ### Simplified Array Format
#
# The simplified array format used in the example above can be obtained with:
#
# ```ruby
# require 'pp'
# pp diffs.map { |e| e.map { |f| f.to_a } }
# ```
class Diff::LCS::ContextDiffCallbacks < Diff::LCS::DiffCallbacks
  def discard_a(event)
    @hunk << Diff::LCS::ContextChange.simplify(event)
  end

  def discard_b(event)
    @hunk << Diff::LCS::ContextChange.simplify(event)
  end

  def change(event)
    @hunk << Diff::LCS::ContextChange.simplify(event)
  end
end

# This will produce a simple array of diff change objects. Each element in the #diffs
# array is a single ContextChange. In the set of #diffs provided by SDiffCallbacks, both
# old and new objects will be presented for both changed <strong>and unchanged</strong>
# objects. `nil` will be substituted for a discarded object.
#
# The diffset produced by this callback, when provided to Diff::LCS#sdiff, will compute
# and display the necessary components to show two sequences and their minimized
# differences side by side, just like the Unix utility `sdiff`.
#
# ```ruby
# # same             same
# # before     |     after
# # old        <     -
# # -          >     new
#
# seq1 = %w(a b c e h j l m n p)
# seq2 = %w(b c d e f j k l m r s t)
#
# diffs = Diff::LCS.sdiff(seq1, seq2)
# # This example shows a simplified array format.
# # [ [ "-", [  0, "a"], [  0, nil ] ],
# #   [ "=", [  1, "b"], [  0, "b" ] ],
# #   [ "=", [  2, "c"], [  1, "c" ] ],
# #   [ "+", [  3, nil], [  2, "d" ] ],
# #   [ "=", [  3, "e"], [  3, "e" ] ],
# #   [ "!", [  4, "h"], [  4, "f" ] ],
# #   [ "=", [  5, "j"], [  5, "j" ] ],
# #   [ "+", [  6, nil], [  6, "k" ] ],
# #   [ "=", [  6, "l"], [  7, "l" ] ],
# #   [ "=", [  7, "m"], [  8, "m" ] ],
# #   [ "!", [  8, "n"], [  9, "r" ] ],
# #   [ "!", [  9, "p"], [ 10, "s" ] ],
# #   [ "+", [ 10, nil], [ 11, "t" ] ] ]
# ```
#
# The result of this operation is similar to that of Diff::LCS::ContextDiffCallbacks. They
# may be compared as:
#
# ```ruby
# s = Diff::LCS.sdiff(seq1, seq2).reject { |e| e.action == "=" }
# c = Diff::LCS.sdiff(seq1, seq2, Diff::LCS::ContextDiffCallbacks).flatten(1)
#
# s == c # => true
# ```
#
# ### Use
#
# This callback object must be initialised and is used by the Diff::LCS#sdiff method.
#
# ```ruby
# cbo = Diff::LCS::SDiffCallbacks.new
# Diff::LCS.lcs(seq1, seq2, cbo)
# ```
#
# This callback also supports initialization with a block, but as there is no "finishing"
# to be done, this has no effect on the state of the object.
#
# ```ruby
# result = Diff::LCS::SDiffCallbacks.new { |cbo| Diff::LCS.lcs(seq1, seq2, cbo) }
# ```
#
# ### Simplified Array Format
#
# The simplified array format used in the example above can be obtained with:
#
# ```ruby
# require 'pp'
# pp diffs.map { |e| e.to_a }
# ```
class Diff::LCS::SDiffCallbacks
  # Returns the difference set collected during the diff process.
  attr_reader :diffs

  def initialize # :yields: self
    @diffs = []
    yield self if block_given?
  end

  def match(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end

  def discard_a(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end

  def discard_b(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end

  def change(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end
end
