# frozen_string_literal: true

# Integration test for RSpec expectation failures that use diff-lcs
# Verifies that diff output is generated correctly with diff-lcs 2.0

RSpec.describe "Diff::LCS 2.0 with RSpec expectations" do
  it "produces diff for failed multiline string equality" do
    expect {
      expect("foo\nbar\nbaz").to eq("foo\nqux\nbaz")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError) do |error|
      expect(error.message).to include("Diff:")
      expect(error.message).to match(/[-+](qux|bar)/)
    end
  end

  it "produces diff for failed hash equality" do
    expect {
      expect({a: 1, b: 2}).to eq({a: 1, b: 3})
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError) do |error|
      expect(error.message).to include("Diff:")
    end
  end

  it "does not crash when comparing complex objects" do
    obj1 = {a: [1, 2, 3], b: "test"}
    obj2 = {a: [1, 4, 3], b: "test"}

    expect {
      expect(obj1).to eq(obj2)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
