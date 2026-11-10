# frozen_string_literal: true

module Diff; end unless defined? Diff
module Diff::LCS; end unless defined? Diff::LCS

# The Data API (keyword or positional construction, `members`, `to_h`, `with`, `eql?`,
# `hash`, frozen instances) for Diff::LCS::Change and Diff::LCS::ContextChange. They are
# built for each element of a traversal, and a Data subclass validating in `initialize`
# allocates three more objects per instance than a plain class (ruby-core#22437).
#
# An including class defines a class-level `members` returning a new Array, like Data, a
# private `member_names` returning the same names without a copy, `values`,
# `deconstruct_keys`, readers, and an `initialize` taking one positional argument per
# member, each defaulting to NO_ARGUMENT, which calls `arguments_to_values` when its last
# argument is NO_ARGUMENT, then freezes.
module Diff::LCS::FrozenValue # :nodoc:
  NO_ARGUMENT = Object.new.freeze
  private_constant :NO_ARGUMENT

  def self.included(base)
    base.singleton_class.alias_method :[], :new
  end

  def members = self.class.members

  def to_h(&) = deconstruct_keys(nil).to_h(&)

  def with(**updates)
    return self if updates.empty?

    self.class.new(**to_h.merge!(updates))
  end

  def eql?(other) = self.class == other.class && values.eql?(other.values)

  def hash = [self.class, values].hash

  def inspect = "#<#{self.class} #{to_h.map { |member, value| "#{member}=#{value.inspect}" }.join(", ")}>"

  alias_method :to_s, :inspect

  # Psych only calls `encode_with` and `init_with` when they are public.
  def encode_with(coder) = to_h.each { |member, value| coder[member.to_s] = value }

  # Like `marshal_load`, goes through `initialize`, so loaded values are validated and
  # frozen.
  def init_with(coder) = initialize(**coder.map.transform_keys { _1.is_a?(String) ? _1.to_sym : _1 })

  private

  # `allocate` must stay defined: Psych calls it before `init_with`, and TruffleRuby's
  # Marshal before `marshal_load`.
  def marshal_load(values) = initialize(*values)

  def marshal_dump = values

  def initialize_copy(*) = super.freeze

  def arguments_to_values(*arguments)
    arguments.pop while NO_ARGUMENT.equal?(arguments.last)
    keywords = arguments.first if arguments.size == 1 && arguments.first.is_a?(Hash)

    # Fewer positional arguments than members: the ones left out are always missing.
    missing = keywords ? member_names.reject { keywords.key?(_1) } : member_names.drop(arguments.size)
    raise_keywords_error("missing", missing) if missing.any?
    raise_keywords_error("unknown", keywords.keys - member_names) if keywords.size > member_names.size

    keywords.values_at(*member_names)
  end

  def raise_keywords_error(kind, keywords)
    raise ArgumentError, "#{kind} keyword#{"s" if keywords.size > 1}: #{keywords.map(&:inspect).join(", ")}"
  end
end
