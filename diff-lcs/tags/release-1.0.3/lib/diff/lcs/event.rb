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

class Diff::LCS::Event
  attr_reader :code
  attr_reader :old_el
  attr_reader :old_ix
  attr_reader :new_el
  attr_reader :new_ix

  def initialize(code, a, ai, b, bi)
    @code = code
    @old_el = a
    @old_ix = ai
    @new_el = b
    @new_ix = bi
  end
end
