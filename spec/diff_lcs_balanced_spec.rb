# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe "Diff::LCS.traverse_balanced should traverse sequences correctly" do
  include Diff::LCS::SpecHelper::Matchers

  def reverse(change_result)
    new_result = []
    change_result.each { |line|
      line = [ line[0], line[2], line[1] ]
      case line[0]
      when '<'
        line[0] = '>'
      when '>'
        line[0] = '<'
      end
      new_result << line
    }
    new_result.sort_by { |line| line[1] }
  end

  def no_change(change_result)
    new_result = []
    change_result.each { |line|
      case line[0]
      when '!'
        new_result << [ '<', line[1], line[2] ]
        new_result << [ '>', line[1] + 1, line[2] ]
      else
        new_result << line
      end
    }
    new_result
  end

  def traverse(s1, s2, callback_type)
    callback = __send__(callback_type)
    Diff::LCS.traverse_balanced(s1, s2, callback)
    callback
  end

  def do_balanced_traversal(s1, s2, result)
    balanced_s1_s2 = traverse(s1, s2, :balanced_callback)
    balanced_s2_s1 = traverse(s2, s1, :balanced_callback)
    balanced_s1_s2_no_change = traverse(s1, s2, :balanced_callback_no_change)
    balanced_s2_s1_no_change = traverse(s2, s1, :balanced_callback_no_change)

    balanced_s1_s2.result.should == result
    balanced_s2_s1.result.should == reverse(result)

    balanced_s1_s2_no_change.result.should == no_change(result)
    balanced_s2_s1_no_change.result.should == no_change(reverse(result))
  end

  it "sequence-a" do
    s1 = %w(a b c)
    s2 = %w(a x c)

    result = [
      [ '=', 0, 0 ],
      [ '!', 1, 1 ],
      [ '=', 2, 2 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-b" do
    s1 = %w(a x y c)
    s2 = %w(a v w c)

    result = [
      [ '=', 0, 0 ],
      [ '!', 1, 1 ],
      [ '!', 2, 2 ],
      [ '=', 3, 3 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-c" do
    s1 = %w(x y c)
    s2 = %w(v w c)
    result = [
      [ '!', 0, 0 ],
      [ '!', 1, 1 ],
      [ '=', 2, 2 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-d" do
    s1 = %w(a x y z)
    s2 = %w(b v w)
    result = [
      [ '!', 0, 0 ],
      [ '!', 1, 1 ],
      [ '!', 2, 2 ],
      [ '<', 3, 3 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-e" do
    s1 = %w(a z)
    s2 = %w(a)
    result = [
      [ '=', 0, 0 ],
      [ '<', 1, 1 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-f" do
    s1 = %w(z a)
    s2 = %w(a)
    result = [
      [ '<', 0, 0 ],
      [ '=', 1, 0 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-g" do
    s1 = %w(a b c)
    s2 = %w(x y z)
    result = [
      [ '!', 0, 0 ],
      [ '!', 1, 1 ],
      [ '!', 2, 2 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-h" do
    s1 = %w(abcd efgh ijkl mnopqrstuvwxyz)
    s2 = []
    result = [
      [ '<', 0, 0 ],
      [ '<', 1, 0 ],
      [ '<', 2, 0 ],
      [ '<', 3, 0 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end

  it "sequence-i" do
    s1 = []
    s2 = %w(abcd efgh ijkl mnopqrstuvwxyz)
    result = [
      [ '>', 0, 0 ],
      [ '>', 0, 1 ],
      [ '>', 0, 2 ],
      [ '>', 0, 3 ]
    ]

    do_balanced_traversal(s1, s2, result)
  end
end

# vim: ft=ruby
