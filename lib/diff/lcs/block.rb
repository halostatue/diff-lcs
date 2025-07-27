# frozen_string_literal: true

Diff::LCS::Block = Data.define(:changes, :insert, :remove) # :nodoc:

# A block is an operation removing, adding, or changing a group of items, a list of
# changes, where each change adds or deletes a single item.
#
# Used by bin/ldiff.
class Diff::LCS::Block
  def self.from_chunk(chunk)
    changes, insert, remove = [], [], []

    chunk.each do
      changes << _1
      remove << _1 if _1.deleting?
      insert << _1 if _1.adding?
    end

    new(changes: changes.freeze, remove: remove.freeze, insert: insert.freeze)
  end

  class << self
    private :new, :[]
  end

  private :with

  def diff_size = insert.size - remove.size

  def op
    case [remove, insert]
    # Unchanged
    in [[], []] then "^"
    # Delete
    in [_, []] then "-"
    # Insert
    in [[], _] then "+"
    # Conflict
    in [_, _] then "!"
    end
  end
end
