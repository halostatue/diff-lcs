# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe "Diff::LCS.sdiff should compare sequences correctly" do
  include Diff::LCS::SpecHelper::Matchers

  def do_sdiff_comparison(s1, s2, forward_sdiff)
    sdiff_s1_s2 = Diff::LCS.sdiff(s1, s2)
    sdiff_s2_s1 = Diff::LCS.sdiff(s2, s1)

    sdiff_s1_s2.should == context_diff(forward_sdiff)
    sdiff_s2_s1.should == context_diff(reverse_sdiff(forward_sdiff))
  end

  it "sequence-a" do
    do_sdiff_comparison(seq1, seq2, correct_forward_sdiff)
  end

  it "sequence-b" do
    s1 = %w(abc def yyy xxx ghi jkl)
    s2 = %w(abc dxf xxx ghi jkl)
    forward_sdiff = [
      [ '=', [ 0, 'abc' ], [ 0, 'abc' ] ],
      [ '!', [ 1, 'def' ], [ 1, 'dxf' ] ],
      [ '-', [ 2, 'yyy' ], [ 2,  nil  ] ],
      [ '=', [ 3, 'xxx' ], [ 2, 'xxx' ] ],
      [ '=', [ 4, 'ghi' ], [ 3, 'ghi' ] ],
      [ '=', [ 5, 'jkl' ], [ 4, 'jkl' ] ]
    ]

    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-c" do
    s1 = %w(a b c d e)
    s2 = %w(a e)
    forward_sdiff = [
      [ '=', [ 0, 'a' ], [ 0, 'a' ] ],
      [ '-', [ 1, 'b' ], [ 1, nil ] ],
      [ '-', [ 2, 'c' ], [ 1, nil ] ],
      [ '-', [ 3, 'd' ], [ 1, nil ] ],
      [ '=', [ 4, 'e' ], [ 1, 'e' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-d" do
    s1 = %w(a e)
    s2 = %w(a b c d e)
    forward_sdiff = [
      [ '=', [ 0, 'a' ], [ 0, 'a' ] ],
      [ '+', [ 1, nil ], [ 1, 'b' ] ],
      [ '+', [ 1, nil ], [ 2, 'c' ] ],
      [ '+', [ 1, nil ], [ 3, 'd' ] ],
      [ '=', [ 1, 'e' ], [ 4, 'e' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-e" do
    s1 = %w(v x a e)
    s2 = %w(w y a b c d e)
    forward_sdiff = [
      [ '!', [ 0, 'v' ], [ 0, 'w' ] ],
      [ '!', [ 1, 'x' ], [ 1, 'y' ] ],
      [ '=', [ 2, 'a' ], [ 2, 'a' ] ],
      [ '+', [ 3, nil ], [ 3, 'b' ] ],
      [ '+', [ 3, nil ], [ 4, 'c' ] ],
      [ '+', [ 3, nil ], [ 5, 'd' ] ],
      [ '=', [ 3, 'e' ], [ 6, 'e' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-f" do
    s1 = %w(x a e)
    s2 = %w(a b c d e)
    forward_sdiff = [
      [ '-', [ 0, 'x' ], [ 0, nil ] ],
      [ '=', [ 1, 'a' ], [ 0, 'a' ] ],
      [ '+', [ 2, nil ], [ 1, 'b' ] ],
      [ '+', [ 2, nil ], [ 2, 'c' ] ],
      [ '+', [ 2, nil ], [ 3, 'd' ] ],
      [ '=', [ 2, 'e' ], [ 4, 'e' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-g" do
    s1 = %w(a e)
    s2 = %w(x a b c d e)
    forward_sdiff = [
      [ '+', [ 0, nil ], [ 0, 'x' ] ],
      [ '=', [ 0, 'a' ], [ 1, 'a' ] ],
      [ '+', [ 1, nil ], [ 2, 'b' ] ],
      [ '+', [ 1, nil ], [ 3, 'c' ] ],
      [ '+', [ 1, nil ], [ 4, 'd' ] ],
      [ '=', [ 1, 'e' ], [ 5, 'e' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-h" do
    s1 = %w(a e v)
    s2 = %w(x a b c d e w x)
    forward_sdiff = [
      [ '+', [ 0, nil ], [ 0, 'x' ] ],
      [ '=', [ 0, 'a' ], [ 1, 'a' ] ],
      [ '+', [ 1, nil ], [ 2, 'b' ] ],
      [ '+', [ 1, nil ], [ 3, 'c' ] ],
      [ '+', [ 1, nil ], [ 4, 'd' ] ],
      [ '=', [ 1, 'e' ], [ 5, 'e' ] ],
      [ '!', [ 2, 'v' ], [ 6, 'w' ] ],
      [ '+', [ 3, nil ], [ 7, 'x' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-i" do
    s1 = %w()
    s2 = %w(a b c)
    forward_sdiff = [
      [ '+', [ 0, nil ], [ 0, 'a' ] ],
      [ '+', [ 0, nil ], [ 1, 'b' ] ],
      [ '+', [ 0, nil ], [ 2, 'c' ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-j" do
    s1 = %w(a b c)
    s2 = %w()
    forward_sdiff = [
      [ '-', [ 0, 'a' ], [ 0, nil ] ],
      [ '-', [ 1, 'b' ], [ 0, nil ] ],
      [ '-', [ 2, 'c' ], [ 0, nil ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-k" do
    s1 = %w(a b c)
    s2 = %w(1)
    forward_sdiff = [
      [ '!', [ 0, 'a' ], [ 0, '1' ] ],
      [ '-', [ 1, 'b' ], [ 1, nil ] ],
      [ '-', [ 2, 'c' ], [ 1, nil ] ] ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-l" do
    s1 = %w(a b c)
    s2 = %w(c)
    forward_sdiff = [
      [ '-', [ 0, 'a' ], [ 0, nil ] ],
      [ '-', [ 1, 'b' ], [ 0, nil ] ],
      [ '=', [ 2, 'c' ], [ 0, 'c' ] ]
    ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-m" do
    s1 = %w(abcd efgh ijkl mnop)
    s2 = []
    forward_sdiff = [
      [ '-', [ 0, 'abcd' ], [ 0, nil ] ],
      [ '-', [ 1, 'efgh' ], [ 0, nil ] ],
      [ '-', [ 2, 'ijkl' ], [ 0, nil ] ],
      [ '-', [ 3, 'mnop' ], [ 0, nil ] ]
    ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end

  it "sequence-n" do
    s1 = []
    s2 = %w(abcd efgh ijkl mnop)
    forward_sdiff = [
      [ '+', [ 0, nil ], [ 0, 'abcd' ] ],
      [ '+', [ 0, nil ], [ 1, 'efgh' ] ],
      [ '+', [ 0, nil ], [ 2, 'ijkl' ] ],
      [ '+', [ 0, nil ], [ 3, 'mnop' ] ]
    ]
    do_sdiff_comparison(s1, s2, forward_sdiff)
  end
end

# vim: ft=ruby
