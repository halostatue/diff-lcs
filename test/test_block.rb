# frozen_string_literal: true

require_relative "test_helper"
require "diff/lcs/block"

class TestBlock < Minitest::Test
  include Diff::LCS::TestHelper

  def test_op_unchanged
    block = Diff::LCS::Block.from_chunk([])
    assert_equal "^", block.op
  end

  def test_op_delete
    changes = [Diff::LCS::Change.new("-", 0, "a")]
    block = Diff::LCS::Block.from_chunk(changes)
    assert_equal "-", block.op
  end

  def test_op_insert
    changes = [Diff::LCS::Change.new("+", 0, "a")]
    block = Diff::LCS::Block.from_chunk(changes)
    assert_equal "+", block.op
  end

  def test_op_conflict
    changes = [
      Diff::LCS::Change.new("-", 0, "a"),
      Diff::LCS::Change.new("+", 0, "b")
    ]
    block = Diff::LCS::Block.from_chunk(changes)
    assert_equal "!", block.op
  end
end
