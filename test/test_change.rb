# frozen_string_literal: true

require "test_helper"

class TestChange < Minitest::Test
  def test_invalid_change
    assert_raises RuntimeError, /Invalid CHange Action/ do
      change("~", 0, "element")
    end

    assert_raises RuntimeError, /Invalid Position Type/ do
      change("+", 3.5, "element")
    end
  end

  def test_from_a
    assert_kind_of Diff::LCS::Change, change_from_a(["+", 0, "element"])
    assert_kind_of Diff::LCS::Change, change_from_a(["+", 0, "element"], Diff::LCS::ContextChange)
    assert_kind_of Diff::LCS::ContextChange,
      change_from_a(["!", [1, "old_element"], [2, "new_element"]])
    assert_kind_of Diff::LCS::ContextChange,
      change_from_a(["!", [1, "old_element"], [2, "new_element"]], Diff::LCS::ContextChange)

    assert_raises RuntimeError, "Invalid change array format provided." do
      change_from_a(["+", 0])
    end

    assert_raises RuntimeError, "Invalid change array format provided." do
      change_from_a(["+", 0], Diff::LCS::ContextChange)
    end
  end

  def test_spaceship_reflexive
    c1 = change("=", 5, "x")
    c2 = change("=", 5, "x")
    assert_equal 0, c1 <=> c2
  end

  def test_spaceship_position_precedence
    c1 = change("=", 5, "x")
    c2 = change("=", 10, "x")

    assert_equal(-1, c1 <=> c2)
    assert_equal 1, c2 <=> c1
  end

  def test_spaceship_action_precedence
    valid_actions.each_cons(2) do |a1, a2|
      c1 = change(a1, 5, "x")
      c2 = change(a2, 5, "x")

      assert_equal(-1, c1 <=> c2, "#{a1} should sort before #{a2}")
      assert_equal 1, c2 <=> c1
    end
  end

  def test_spaceship_element_precedence
    c1 = change("=", 5, "a")
    c2 = change("=", 5, "z")

    assert_equal(-1, c1 <=> c2)
    assert_equal 1, c2 <=> c1
    assert_equal 0, c1 <=> change("=", 5, "a")
  end

  def test_add
    change = change("+", 0, "element")

    assert change.adding?

    refute change.deleting?
    refute change.unchanged?
    refute change.changed?
    refute change.finished_a?
    refute change.finished_b?
  end

  def test_delete
    change = change("-", 0, "element")

    assert change.deleting?

    refute change.adding?
    refute change.unchanged?
    refute change.changed?
    refute change.finished_a?
    refute change.finished_b?
  end

  def test_unchanged
    change = change("=", 0, "element")

    assert change.unchanged?

    refute change.deleting?
    refute change.adding?
    refute change.changed?
    refute change.finished_a?
    refute change.finished_b?
  end

  def test_changed
    change = change("!", 0, "element")

    assert change.changed?

    refute change.deleting?
    refute change.adding?
    refute change.unchanged?
    refute change.finished_a?
    refute change.finished_b?
  end

  def test_finished_a
    change = change(">", 0, "element")

    assert change.finished_a?

    refute change.deleting?
    refute change.adding?
    refute change.unchanged?
    refute change.changed?
    refute change.finished_b?
  end

  def test_finished_b
    change = change("<", 0, "element")

    assert change.finished_b?

    refute change.deleting?
    refute change.adding?
    refute change.unchanged?
    refute change.changed?
    refute change.finished_a?
  end

  def test_as_array
    action, position, element = change("!", 0, "element")
    assert_equal "!", action
    assert_equal 0, position
    assert_equal "element", element
  end
end

class TestContextChange < Minitest::Test
  private def change(...) = Diff::LCS::ContextChange.new(...)
  private def simplify(...) = Diff::LCS::ContextChange.simplify(change(...))

  def test_invalid_change
    assert_raises RuntimeError, /Invalid CHange Action/ do
      change("~", 0, "old", 0, "new")
    end

    assert_raises RuntimeError, /Invalid Position Type/ do
      change("+", 3.5, "old", 0, "new")
    end

    assert_raises RuntimeError, /Invalid Position Type/ do
      change("+", 0, "old", 3.5, "new")
    end
  end

  def test_as_array
    action, old, new = change("!", 1, "old_element", 2, "new_element")

    assert_equal "!", action
    assert_equal [1, "old_element"], old
    assert_equal [2, "new_element"], new
  end

  def test_spaceship_reflexive
    c1 = change("=", 5, "x", 10, "y")
    c2 = change("=", 5, "x", 10, "y")
    assert_equal 0, c1 <=> c2
  end

  def test_spaceship_position_precedence
    c1 = change("=", 5, "x", 10, "y")
    c2 = change("=", 15, "x", 10, "y")

    assert_equal(-1, c1 <=> c2)
    assert_equal 1, c2 <=> c1

    c1 = change("=", 5, "x", 10, "y")
    c2 = change("=", 5, "x", 20, "y")

    assert_equal(-1, c1 <=> c2)
    assert_equal 1, c2 <=> c1
  end

  def test_spaceship_action_precedence
    valid_actions.each_cons(2) do |a1, a2|
      c1 = change(a1, 5, "x", 10, "y")
      c2 = change(a2, 5, "x", 10, "y")

      assert_equal(-1, c1 <=> c2, "#{a1} should sort before #{a2}")
      assert_equal 1, c2 <=> c1
    end
  end

  def test_spaceship_element_precedence
    c1 = change("=", 5, "a", 10, "y")
    c2 = change("=", 5, "z", 10, "y")

    assert_equal(-1, c1 <=> c2, "old_element precedence")
    assert_equal 1, c2 <=> c1

    c3 = change("=", 5, "x", 10, "a")
    c4 = change("=", 5, "x", 10, "z")

    assert_equal(-1, c3 <=> c4, "new_element precedence")
    assert_equal 1, c4 <=> c3
    assert_equal 0, c3 <=> Diff::LCS::ContextChange.new("=", 5, "x", 10, "a")
  end

  def test_simplify
    simplify("-", 5, "old", 10, "new") => {action:, new_element:}
    assert_equal action, "-"
    assert_nil new_element

    simplify("<", 5, "old", 10, "new") => {action:, new_element:}
    assert_equal action, "-"
    assert_nil new_element

    simplify("+", 5, "old", 10, "new") => {action:, old_element:}
    assert_equal action, "+"
    assert_nil old_element

    simplify(">", 5, "old", 10, "new") => {action:, old_element:}
    assert_equal action, "+"
    assert_nil old_element
  end
end
