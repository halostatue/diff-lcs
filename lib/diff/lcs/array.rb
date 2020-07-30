# frozen_string_literal: true
# typed: strict

require 'diff/lcs'

warn 'diff/lcs/array: Automatically extending Array with Diff::LCS is deprecated'

class Array #:nodoc:
  include Diff::LCS
end
