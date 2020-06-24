# frozen_string_literal: true

require 'spec_helper'
require 'diff/lcs/hunk'

describe 'Diff::LCS Issues' do
  include Diff::LCS::SpecHelper::Matchers

  describe 'issue #1' do
    shared_examples 'handles simple diffs' do |s1, s2, forward_diff|
      before do
        @diff_s1_s2 = Diff::LCS.diff(s1, s2)
      end

      it 'creates the correct diff' do
        expect(change_diff(forward_diff)).to eq(@diff_s1_s2)
      end

      it 'creates the correct patch s1->s2' do
        expect(Diff::LCS.patch(s1, @diff_s1_s2)).to eq(s2)
      end

      it 'creates the correct patch s2->s1' do
        expect(Diff::LCS.patch(s2, @diff_s1_s2)).to eq(s1)
      end
    end

    describe 'string' do
      it_has_behavior 'handles simple diffs', 'aX', 'bXaX', [
        [
          ['+', 0, 'b'],
          ['+', 1, 'X']
        ]
      ]
      it_has_behavior 'handles simple diffs', 'bXaX', 'aX', [
        [
          ['-', 0, 'b'],
          ['-', 1, 'X']
        ]
      ]
    end

    describe 'array' do
      it_has_behavior 'handles simple diffs', %w(a X), %w(b X a X), [
        [
          ['+', 0, 'b'],
          ['+', 1, 'X']
        ]
      ]
      it_has_behavior 'handles simple diffs', %w(b X a X), %w(a X), [
        [
          ['-', 0, 'b'],
          ['-', 1, 'X']
        ]
      ]
    end
  end

  describe "issue #57" do
    it 'should fail with a correct error' do
      expect {
        actual = {:category=>"app.rack.request"}
        expected = {:category=>"rack.middleware", :title=>"Anonymous Middleware"}
        expect(actual).to eq(expected)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  describe "issue #60" do
    it 'should produce unified output with correct context' do
      old_data = <<-DATA_OLD.strip.split("\n").map(&:chomp)
{
  "name": "x",
  "description": "hi"
}
      DATA_OLD

      new_data = <<-DATA_NEW.strip.split("\n").map(&:chomp)
{
  "name": "x",
  "description": "lo"
}
      DATA_NEW

      diff = ::Diff::LCS.diff(old_data, new_data)
      hunk = ::Diff::LCS::Hunk.new(old_data, new_data, diff.first, 3, 0)

      expect(hunk.diff(:unified)).to eq(<<-EXPECTED.chomp)
@@ -1,5 +1,5 @@
 {
   "name": "x",
-  "description": "hi"
+  "description": "lo"
 }
      EXPECTED
    end
  end
end
