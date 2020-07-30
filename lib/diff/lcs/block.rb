# frozen_string_literal: true
# typed: strict

# A block is an operation removing, adding, or changing a group of items.
# Basically, this is just a list of changes, where each change adds or
# deletes a single item. Used by bin/ldiff.
class Diff::LCS::Block
  extend T::Sig

  ArrayOfChange = T.type_alias { T::Array[Diff::LCS::Change] }

  # The full set of changes in the block.
  sig { returns(ArrayOfChange) }
  attr_reader :changes

  # The insertions in the block.
  sig { returns(ArrayOfChange) }
  attr_reader :insert

  # The deletions in the block.
  sig { returns(ArrayOfChange) }
  attr_reader :remove

  sig { params(chunk: ArrayOfChange).void }
  def initialize(chunk)
    @changes = T.let([], ArrayOfChange)
    @insert = T.let([], ArrayOfChange)
    @remove = T.let([], ArrayOfChange)

    chunk.each do |item|
      @changes << item
      @remove << item if item.deleting?
      @insert << item if item.adding?
    end
  end

  sig { returns(Integer) }
  def diff_size
    insert.size - remove.size
  end

  sig { returns(String) }
  def op
    case [remove.empty?, insert.empty?]
    when [false, false]
      '!'
    when [false, true]
      '-'
    when [true, false]
      '+'
    else # [true, true]
      '^'
    end
  end
end
