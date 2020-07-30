# frozen_string_literal: true
# typed: strict

# Represents a simplistic (non-contextual) change. Represents the removal or
# addition of an element from either the old or the new sequenced
# enumerable.
class Diff::LCS::Change
  extend T::Sig

  ArrayT = T.type_alias{
    T.any(
      [String, Integer, T.untyped],
      [String, Integer, T.untyped, Integer, T.untyped],
      [String, [Integer, T.untyped], [Integer, T.untyped]]
    )
  }

  ChangeT = T.type_alias { T.any(Diff::LCS::Change, Diff::LCS::ContextChange) }

  # The only actions valid for changes are '+' (add), '-' (delete), '='
  # (no change), '!' (changed), '<' (tail changes from first sequence), or
  # '>' (tail changes from second sequence). The last two ('<>') are only
  # found with Diff::LCS::diff and Diff::LCS::sdiff.
  VALID_ACTIONS = T.let(%w(+ - = ! > <).freeze, T::Array[String])

  sig { params(action: T.any(String, Diff::LCS::Change)).returns(T::Boolean) }
  def self.valid_action?(action)
    return false unless action.kind_of?(String)

    VALID_ACTIONS.include?(action)
  end

  # Returns the action this Change represents.
  sig { returns(String) }
  attr_reader :action

  # Returns the position of the Change.
  sig { returns(Integer) }
  attr_reader :position

  # Returns the sequence element of the Change.
  sig { returns(T.untyped) }
  attr_reader :element

  sig {
    params(
      action: String,
      position: Integer,
      element: T.untyped,
      _: T.untyped
    ).void
  }
  def initialize(action, position, element, *_)
    @action = action
    @position = position
    @element = element

    fail "Invalid Change Action '#{@action}'" unless Diff::LCS::Change.valid_action?(@action)
    fail 'Invalid Position Type' unless @position.kind_of? Integer
  end

  sig { params(_args: T.untyped).returns(String) }
  def inspect(*_args)
    "#<#{self.class}: #{to_a.inspect}>"
  end

  sig { returns(ArrayT) }
  def to_a
    [@action, @position, @element]
  end

  alias to_ary to_a

  sig { params(arr: ArrayT).returns(ChangeT) }
  def self.from_a(arr)
    arr = arr.flatten(1)
    case arr.size
    when 5
      Diff::LCS::ContextChange.new(arr[0], arr[1], arr[2], arr[3], arr[4])
    when 3
      Diff::LCS::Change.new(arr[0], arr[1], arr[2])
    else
      fail 'Invalid change array format provided.'
    end
  end

  include Comparable

  sig { params(other: ChangeT).returns(T::Boolean) }
  def ==(other)
    self.class == other.class &&
      action == other.action &&
      position == other.position &&
      element == other.element
  end

  sig { params(other: Diff::LCS::Change).returns(Integer) }
  def <=>(other)
    r = action <=> other.action
    r = position <=> other.position if T.must(r).zero?
    r = element <=> other.element if T.must(r).zero?
    r
  end

  sig { returns(T::Boolean) }
  def adding?
    @action == '+'
  end

  sig { returns(T::Boolean) }
  def deleting?
    @action == '-'
  end

  sig { returns(T::Boolean) }
  def unchanged?
    @action == '='
  end

  sig { returns(T::Boolean) }
  def changed?
    @action == '!'
  end

  sig { returns(T::Boolean) }
  def finished_a?
    @action == '>'
  end

  sig { returns(T::Boolean) }
  def finished_b?
    @action == '<'
  end
end

# Represents a contextual change. Contains the position and values of the
# elements in the old and the new sequenced enumerables as well as the action
# taken.
class Diff::LCS::ContextChange < Diff::LCS::Change
  extend T::Sig

  # We don't need these two values.
  undef :position
  undef :element

  # Returns the old position being changed.
  sig { returns(Integer) }
  attr_reader :old_position

  # Returns the new position being changed.
  sig { returns(Integer) }
  attr_reader :new_position

  # Returns the old element being changed.
  sig { returns(T.untyped) }
  attr_reader :old_element

  # Returns the new element being changed.
  sig { returns(T.untyped) }
  attr_reader :new_element

  sig {
    params(
      action: String,
      old_position: Integer,
      old_element: T.untyped,
      new_position: Integer,
      new_element: T.untyped,
      _: T.untyped
    ).void
  }
  def initialize(action, old_position, old_element, new_position, new_element, *_)
    @action = action
    @old_position = old_position
    @old_element = old_element
    @new_position = new_position
    @new_element = new_element

    fail "Invalid Change Action '#{@action}'" unless Diff::LCS::Change.valid_action?(@action)
    fail 'Invalid (Old) Position Type' unless @old_position.nil? or @old_position.kind_of? Integer
    fail 'Invalid (New) Position Type' unless @new_position.nil? or @new_position.kind_of? Integer
  end

  sig { returns(ArrayT) }
  def to_a
    [
      @action,
      [@old_position, @old_element],
      [@new_position, @new_element]
    ]
  end

  alias to_ary to_a

  sig { params(action: String).returns(Diff::LCS::Change) }
  def to_change(action)
    case action
    when '-'
      Diff::LCS::Change.new(action, old_position, old_element)
    when '+'
      Diff::LCS::Change.new(action, new_position, new_element)
    else
      fail 'Invalid action for creating a change'
    end
  end

  sig { params(arr: ArrayT).returns(ChangeT) }
  def self.from_a(arr)
    Diff::LCS::Change.from_a(arr)
  end

  # Simplifies a context change for use in some diff callbacks. '<' actions
  # are converted to '-' and '>' actions are converted to '+'.
  sig { returns(T.any(Diff::LCS::Change, Diff::LCS::ContextChange)) }
  def simplify
    args =
      case action
      when '-', '<'
        ['-', [old_position, old_element], [new_position, nil]]
      when '+', '>'
        ['+', [old_position, nil], [new_position, new_element]]
      else
        to_a
      end

    self.class.from_a(args)
  end

  # Simplifies a context change for use in some diff callbacks. '<' actions
  # are converted to '-' and '>' actions are converted to '+'.
  sig {
    params(event: Diff::LCS::ContextChange).returns(T.any(
      Diff::LCS::Change,
      Diff::LCS::ContextChange
    ))
  }
  def self.simplify(event)
    event.simplify
  end

  sig { params(other: ChangeT).returns(T::Boolean) }
  def ==(other)
    return false unless other.kind_of?(Diff::LCS::ContextChange)

    @action == other.action &&
      @old_position == other.old_position &&
      @new_position == other.new_position &&
      @old_element == other.old_element &&
      @new_element == other.new_element
  end

  sig { params(other: Diff::LCS::ContextChange).returns(Integer) }
  def <=>(other)
    r = @action <=> other.action
    r = @old_position <=> other.old_position if T.must(r).zero?
    r = @new_position <=> other.new_position if T.must(r).zero?
    r = @old_element <=> other.old_element if T.must(r).zero?
    r = @new_element <=> other.new_element if r.zero?
    r
  end
end
