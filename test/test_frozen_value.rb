# frozen_string_literal: true

require "test_helper"
require "yaml"

# Diff::LCS::Change and ContextChange keep the API they had as Data classes, checked
# against Data classes with the same members.
class TestFrozenValue < Minitest::Test
  CHANGE = Diff::LCS::Change
  CONTEXT_CHANGE = Diff::LCS::ContextChange
  DATA_BY_CLASS = {
    CHANGE => Data.define(*CHANGE.members),
    CONTEXT_CHANGE => Data.define(*CONTEXT_CHANGE.members)
  }.freeze

  def context_change = CONTEXT_CHANGE.new("!", 1, "old", 2, "new")

  # The members (`to_h`) of the value built by `operation` on `klass`, or the message of
  # the ArgumentError it raised.
  def outcome(klass, &operation)
    operation.call(klass).to_h
  rescue ArgumentError => exception
    exception.message
  end

  def assert_outcome_matches_data(klass, &operation)
    assert_equal outcome(DATA_BY_CLASS.fetch(klass), &operation), outcome(klass, &operation)
  end

  def test_construction_matches_data
    assert_outcome_matches_data(CHANGE) { _1.new("+", 0, "a") }
    assert_outcome_matches_data(CHANGE) { _1["+", 0, "a"] }
    assert_outcome_matches_data(CHANGE) { _1.new(action: "+", position: 0, element: "a") }
    assert_outcome_matches_data(CHANGE) { _1[element: "a", position: 0, action: "+"] }
    assert_outcome_matches_data(CHANGE) { _1.new("+", 0) }
    assert_outcome_matches_data(CHANGE) { _1.new }
    assert_outcome_matches_data(CHANGE) { _1.new(action: "+", position: 0, element: "a", extra: 1) }
    assert_outcome_matches_data(CONTEXT_CHANGE) { _1.new("!", 1, "old", 2, "new") }
    assert_outcome_matches_data(CONTEXT_CHANGE) { _1.new(action: "+", old_position: 0, new_element: "a") }
    assert_raises(ArgumentError) { CHANGE.new("+", 0, "a", "b") }
  end

  def test_with_matches_data
    [
      [CHANGE, ["+", 0, "a"], {}],
      [CHANGE, ["+", 0, "a"], {position: 1}],
      [CHANGE, ["+", 0, "a"], {element: nil, action: "-"}],
      [CHANGE, ["+", 0, "a"], {extra: 1}],
      [CONTEXT_CHANGE, ["<", 1, "old", 2, "new"], {action: "-", new_element: nil}],
      [CONTEXT_CHANGE, ["<", 1, "old", 2, "new"], {position: 3}]
    ].each do |klass, values, updates|
      assert_outcome_matches_data(klass) { _1.new(*values).with(**updates) }
    end

    assert_outcome_matches_data(CHANGE) { _1.new("+", 0, "a").with(3) }
  end

  def test_with_validates_and_returns_self_without_changes
    change = context_change

    assert_same change, change.with
    assert_raises_with_message RuntimeError, "Invalid Change Action '~'" do
      change.with(action: "~")
    end
  end

  def test_keyword_construction_validates
    assert_raises_with_message RuntimeError, "Invalid Position Type" do
      CHANGE.new(action: "+", position: "0", element: "a")
    end
  end

  def test_members_and_to_h
    assert_equal %i[action position element], CHANGE.members
    assert_equal %i[action old_position old_element new_position new_element], context_change.members
    CHANGE.members << :extra
    context_change.members << :extra
    assert_equal %i[action position element], CHANGE.members
    refute_respond_to context_change, :marshal_dump
    assert_equal({"action" => "+", "position" => 0, "element" => "a"},
      CHANGE.new("+", 0, "a").to_h { |member, value| [member.to_s, value] })
  end

  def test_to_h_returns_a_hash_of_its_own
    change = CHANGE.new("+", 0, "a")
    change.to_h[:position] = 1

    assert_equal({action: "+", position: 0, element: "a"}, change.to_h)
  end

  # Telling these apart from a Hash given as the last member would take a keyword
  # parameter, which allocates on every positional call.
  def test_a_hash_as_only_or_last_argument_is_not_rejected_like_data
    assert_equal CHANGE.new("+", 0, "a"), CHANGE.new({action: "+", position: 0, element: "a"})
    assert_equal({element: "a"}, CHANGE.new("+", 0, element: "a").element)
  end

  def test_value_equality_as_hash_keys
    counts = Hash.new(0)
    2.times { counts[CONTEXT_CHANGE.new("!", 1, "old", 2, "new")] += 1 }
    counts[CONTEXT_CHANGE.new("!", 1, "old", 2, "other")] += 1

    assert_equal [2, 1], counts.values
    refute CHANGE.new("+", 1, 1).eql?(CHANGE.new("+", 1, 1.0))
    refute CHANGE.new("+", 1, 1).eql?(CONTEXT_CHANGE.new("+", 1, 1, 1, 1))
  end

  def test_instances_and_their_copies_are_frozen
    change = CHANGE.new("+", 0, "a")

    assert_predicate change, :frozen?
    assert_predicate change.dup, :frozen?
    assert_predicate change.clone(freeze: false), :frozen?
    assert_raises(FrozenError) { change.instance_variable_set(:@position, 1) }
    assert_raises(FrozenError) { change.send(:marshal_load, ["-", 1, "b"]) }
  end

  def test_marshal_round_trip
    copy = Marshal.load(Marshal.dump(context_change))

    assert_equal context_change, copy
    assert_predicate copy, :frozen?
  end

  def test_yaml_round_trip
    copy = YAML.unsafe_load(YAML.dump(context_change))

    assert_equal context_change, copy
    assert_predicate copy, :frozen?
    assert_raises_with_message RuntimeError, "Invalid Change Action '~'" do
      YAML.unsafe_load(YAML.dump(CHANGE.new("+", 0, "a")).sub('"+"', '"~"'))
    end
  end

  def test_yaml_load_requires_exactly_the_members
    dump = YAML.dump(CHANGE.new("+", 0, "a"))

    assert_raises_with_message ArgumentError, "missing keyword: :element" do
      YAML.unsafe_load(dump.sub(/^element: .*\n/, ""))
    end
    assert_raises_with_message ArgumentError, "unknown keyword: :extra" do
      YAML.unsafe_load("#{dump}extra: 1\n")
    end
    assert_raises_with_message ArgumentError, "unknown keyword: 1" do
      YAML.unsafe_load("#{dump}1: 2\n")
    end
  end

  def test_inspect_and_to_s
    assert_equal '#<Diff::LCS::ContextChange action="!", old_position=1, old_element="old", ' \
      'new_position=2, new_element="new">', context_change.to_s
    assert_equal '#<Diff::LCS::Change: ["+", 0, "a"]>', CHANGE.new("+", 0, "a").inspect
    assert_equal '#<Diff::LCS::Change action="+", position=0, element="a">', CHANGE.new("+", 0, "a").to_s
  end
end
