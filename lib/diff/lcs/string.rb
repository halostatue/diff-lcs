# frozen_string_literal: true
# typed: strict

warn 'diff/lcs/string: Automatically extending String with Diff::LCS is deprecated'

class String # :nodoc:
  include Diff::LCS
end
