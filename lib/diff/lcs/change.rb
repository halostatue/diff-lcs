# frozen_string_literal: true

Diff::LCS::Change = Data.define(:action, :position, :element) # :nodoc:
Diff::LCS::ContextChange = Data.define(:action, :old_position, :old_element, :new_position, :new_element) # :nodoc:

# Represents a simplistic (non-contextual) change. Represents the removal or addition of
# an element from either the old or the new sequenced enumerable.
class Diff::LCS::Change
  # The only actions valid for changes are '+' (add), '-' (delete), '=' (no change), '!'
  # (changed), '<' (tail changes from first sequence), or '>' (tail changes from second
  # sequence). The last two ('<>') are only found with Diff::LCS::diff and
  # Diff::LCS::sdiff.
  VALID_ACTIONS = %w[+ - = ! > <].freeze

  def self.valid_action?(action) = VALID_ACTIONS.include?(action)

  ##
  # Returns the action this Change represents.
  # :attr_reader: action

  ##
  # Returns the position of the Change.
  # :attr_reader: position

  ##
  # Returns the sequence element of the Change.
  # :attr_reader: element

  def initialize(action:, position:, element:)
    fail "Invalid Change Action '#{action}'" unless Diff::LCS::Change.valid_action?(action)
    fail "Invalid Position Type" unless position.is_a?(Integer)

    super
  end

  def inspect(*_args) = "#<#{self.class}: #{to_a.inspect}>"

  def to_a = [action, position, element]
  alias_method :to_ary, :to_a

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
    r = action <=> other.action
    r = position <=> other.position if r.zero?
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
  ##
  # Returns the action this Change represents.
  # :attr_reader: action

  ##
  # Returns the old position being changed.
  # :attr_reader: old_position

  ##
  # Returns the new position being changed.
  # :attr_reader: new_position

  ##
  # Returns the old element being changed.
  # :attr_reader: old_element

  ##
  # Returns the new element being changed.
  # :attr_reader: new_element

  def initialize(action:, old_position:, old_element:, new_position:, new_element:)
    fail "Invalid Change Action '#{action}'" unless Diff::LCS::Change.valid_action?(action)
    fail "Invalid (Old) Position Type" unless old_position.nil? || old_position.is_a?(Integer)
    fail "Invalid (New) Position Type" unless new_position.nil? || new_position.is_a?(Integer)

    super
  end

  def to_a = [action, [old_position, old_element], [new_position, new_element]]
  alias_method :to_ary, :to_a

  def self.from_a(arr) = Diff::LCS::Change.from_a(arr)

  # Simplifies a context change for use in some diff callbacks. '<' actions are converted
  # to '-' and '>' actions are converted to '+'.
  def self.simplify(event)
    ea = event.to_a

    case ea[0]
    when "-"
      ea[2][1] = nil
    when "<"
      ea[0] = "-"
      ea[2][1] = nil
    when "+"
      ea[1][1] = nil
    when ">"
      ea[0] = "+"
      ea[1][1] = nil
    end

    from_a(ea)
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
    r = action <=> other.action
    r = old_position <=> other.old_position if r.zero?
    r = new_position <=> other.new_position if r.zero?
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
