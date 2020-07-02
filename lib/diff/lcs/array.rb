# frozen_string_literal: true

require 'diff/lcs'

warn 'diff/lcs/array: Automatically extending Array with Diff::LCS is deprecated'

class Array #:nodoc:
  include Diff::LCS
end
