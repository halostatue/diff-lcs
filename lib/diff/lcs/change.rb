# frozen_string_literal: true

require "diff/lcs/frozen_value"

# Represents a simplistic (non-contextual) change. Represents the removal or addition of
# an element from either the old or the new sequenced enumerable.
class Diff::LCS::Change
  include Diff::LCS::FrozenValue

  # The only actions valid for changes are '+' (add), '-' (delete), '=' (no change), '!'
  # (changed), '<' (tail changes from first sequence), or '>' (tail changes from second
  # sequence). The last two ('<>') are only found with Diff::LCS::diff and
  # Diff::LCS::sdiff.
  VALID_ACTIONS = %w[= - + ! > <].freeze

  def self.valid_action?(action) = VALID_ACTIONS.include?(action)

  MEMBERS = %i[action position element].freeze
  private_constant :MEMBERS

  # Returns the member names of a Change, in the order of its positional arguments.
  def self.members = MEMBERS.dup

  # Returns the action this Change represents.
  attr_reader :action

  # Returns the position of the Change.
  attr_reader :position

  # Returns the sequence element of the Change.
  attr_reader :element

  # :call-seq:
  #   new(action, position, element) -> change
  #   new(action:, position:, element:) -> change
  #
  # Returns a new frozen Change. `action` must be one of VALID_ACTIONS and `position`
  # must be an Integer.
  def initialize(action = NO_ARGUMENT, position = NO_ARGUMENT, element = NO_ARGUMENT)
    action, position, element = arguments_to_values(action, position, element) if NO_ARGUMENT.equal?(element)

    fail "Invalid Change Action '#{action}'" unless Diff::LCS::Change.valid_action?(action)
    fail "Invalid Position Type" unless position.is_a?(Integer)

    @action = action
    @position = position
    @element = element
    freeze
  end

  def inspect(*_args) = "#<#{self.class}: #{to_a.inspect}>"

  def to_a = [action, position, element]
  alias_method :to_ary, :to_a
  alias_method :deconstruct, :to_a

  def deconstruct_keys(_) = {action:, position:, element:}

  protected def values # :nodoc:
    [@action, @position, @element]
  end

  private def member_names = MEMBERS

  def self.from_a(arr)
    case arr
    in [action, [old_position, old_element], [new_position, new_element]]
      Diff::LCS::ContextChange[action, old_position, old_element, new_position, new_element]
    in [action, position, element]
      new(action, position, element)
    else
      fail "Invalid change array format provided."
    end
  end

  include Comparable

  def ==(other)
    (self.class == other.class) and
      (action == other.action) and
      (position == other.position) and
      (element == other.element)
  end

  def <=>(other)
    r = position <=> other.position
    r = VALID_ACTIONS.index(action) <=> VALID_ACTIONS.index(other.action) if r.zero?
    r = element <=> other.element if r.zero?
    r
  end

  def adding? = action == "+"

  def deleting? = action == "-"

  def unchanged? = action == "="

  def changed? = action == "!"

  def finished_a? = action == ">"

  def finished_b? = action == "<"
end

# Represents a contextual change. Contains the position and values of the elements in the
# old and the new sequenced enumerable values as well as the action taken.
class Diff::LCS::ContextChange
  include Diff::LCS::FrozenValue

  MEMBERS = %i[action old_position old_element new_position new_element].freeze
  private_constant :MEMBERS

  # Returns the member names of a ContextChange, in the order of its positional arguments.
  def self.members = MEMBERS.dup

  # Returns the action this Change represents.
  attr_reader :action

  # Returns the old position being changed.
  attr_reader :old_position

  # Returns the old element being changed.
  attr_reader :old_element

  # Returns the new position being changed.
  attr_reader :new_position

  # Returns the new element being changed.
  attr_reader :new_element

  # :call-seq:
  #   new(action, old_position, old_element, new_position, new_element) -> context_change
  #   new(action:, old_position:, old_element:, new_position:, new_element:) -> context_change
  #
  # Returns a new frozen ContextChange. `action` must be one of Change::VALID_ACTIONS,
  # and each position must be an Integer or `nil`.
  def initialize(action = NO_ARGUMENT, old_position = NO_ARGUMENT, old_element = NO_ARGUMENT, new_position = NO_ARGUMENT, new_element = NO_ARGUMENT)
    if NO_ARGUMENT.equal?(new_element)
      action, old_position, old_element, new_position, new_element =
        arguments_to_values(action, old_position, old_element, new_position, new_element)
    end

    fail "Invalid Change Action '#{action}'" unless Diff::LCS::Change.valid_action?(action)
    fail "Invalid (Old) Position Type" unless old_position.nil? || old_position.is_a?(Integer)
    fail "Invalid (New) Position Type" unless new_position.nil? || new_position.is_a?(Integer)

    @action = action
    @old_position = old_position
    @old_element = old_element
    @new_position = new_position
    @new_element = new_element
    freeze
  end

  def to_a = [action, [old_position, old_element], [new_position, new_element]]
  alias_method :to_ary, :to_a
  alias_method :deconstruct, :to_a

  def deconstruct_keys(_) = {action:, old_position:, old_element:, new_position:, new_element:}

  protected def values # :nodoc:
    [@action, @old_position, @old_element, @new_position, @new_element]
  end

  private def member_names = MEMBERS

  def self.from_a(arr) = Diff::LCS::Change.from_a(arr)

  # Simplifies a context change for use in some diff callbacks. '<' actions are converted
  # to '-' and '>' actions are converted to '+'.
  def self.simplify(event)
    case event.action
    when "-", "<"
      event.class.new("-", event.old_position, event.old_element, event.new_position, nil)
    when "+", ">"
      event.class.new("+", event.old_position, nil, event.new_position, event.new_element)
    else
      event
    end
  end

  def ==(other)
    (self.class == other.class) &&
      (action == other.action) &&
      (old_position == other.old_position) &&
      (new_position == other.new_position) &&
      (old_element == other.old_element) &&
      (new_element == other.new_element)
  end

  def <=>(other)
    r = old_position <=> other.old_position
    r = new_position <=> other.new_position if r.zero?
    if r.zero?
      r = Diff::LCS::Change::VALID_ACTIONS.index(action) <=>
        Diff::LCS::Change::VALID_ACTIONS.index(other.action)
    end
    r = old_element <=> other.old_element if r.zero?
    r = new_element <=> other.new_element if r.zero?
    r
  end

  def adding? = action == "+"

  def deleting? = action == "-"

  def unchanged? = action == "="

  def changed? = action == "!"

  def finished_a? = action == ">"

  def finished_b? = action == "<"
end
