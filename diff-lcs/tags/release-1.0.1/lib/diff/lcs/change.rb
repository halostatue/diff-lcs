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

class Diff::LCS::Change
  attr_reader :action, :position, :text

  include Comparable

  def ==(other)
    (self.action == other.action) and
    (self.position == other.position) and
    (self.text == other.text)
  end

  def <=>(other)
    r = self.action <=> other.action
    r = self.position <=> other.position if r.zero?
    r = self.text <=> other.text if r.zero?
    r
  end

  def initialize(action, position, text)
    @action = action
    @position = position
    @text = text
  end

  def to_a
    [@action, @position, @text]
  end

  def self.from_a(*arr)
    Diff::LCS::Change.new(arr[0], arr[1], arr[2])
  end

  def deleting?
    @action == :-
  end

  def adding?
    @action == :+
  end

  def unchanged?
    @action == :u
  end

  def changed?
    @changed == :c
  end
end
