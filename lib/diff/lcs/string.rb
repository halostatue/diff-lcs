# frozen_string_literal: true

warn 'diff/lcs/string: Automatically extending String with Diff::LCS is deprecated'

class String # :nodoc:
  include Diff::LCS
end
