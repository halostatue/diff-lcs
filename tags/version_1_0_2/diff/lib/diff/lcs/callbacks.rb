#! /usr/env/bin ruby
#--
# Copyright 2004 Austin Ziegler <diff-lcs@halostatue.ca>
#   adapted from:
#     Algorithm::Diff (Perl) by Ned Konz <perl@bike-nomad.com>
#     Smalltalk by Mario I. Wolczko <mario@wolczko.com>
#   implements McIlroy-Hunt diff algorithm
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later), the Perl Artistic licence, or the
# Ruby licence.
# 
# $Id$
#++

require 'diff/lcs/change'

class Diff::LCS::SequenceCallbacks #:nodoc:
  class << self
    def match(event)
      event
    end
    def discard_a(event)
      event
    end
    def discard_b(event)
      event
    end
  end
end

class Diff::LCS::BalancedCallbacks #:nodoc:
  class << self
    def match(event)
      event
    end
    def discard_a(event)
      event
    end
    def discard_b(event)
      event
    end
  end
end

class Diff::LCS::DiffCallbacks #:nodoc:
  attr_accessor :hunk
  attr_accessor :diffs

  def initialize
    @hunk = []
    @diffs = []
  end

  def match(event)
    @diffs << @hunk unless @hunk.empty?
    @hunk = []
  end

  def discard_a(event)
    @hunk << Diff::LCS::Change.new('-', event.old_ix, event.old_el)
  end

  def discard_b(event)
    @hunk << Diff::LCS::Change.new('+', event.new_ix, event.new_el)
  end
end

class Diff::LCS::SDiffCallbacks #:nodoc:
  attr_accessor :diffs

  def initialize
    @diffs = []
  end

  def match(event)
    @diffs << Diff::LCS::Change.new('u', event.old_el, event.new_el)
  end

  def discard_a(event)
    @diffs << Diff::LCS::Change.new('-', event.old_el, nil)
  end

  def discard_b(event)
    @diffs << Diff::LCS::Change.new('+', nil, event.new_el)
  end

  def change(event)
    @diffs << Diff::LCS::Change.new('!', event.old_el, event.new_el)
  end
end

class Diff::LCS::YieldingCallbacks #:nodoc:
  class << self
    def method_missing(symbol, *args)
      yield args if block_given?
    end
  end
end
