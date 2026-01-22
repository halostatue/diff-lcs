# frozen_string_literal: true

# Integration test to verify diff-lcs 2.0 works with RSpec's differ
# This runs RSpec with diff-lcs 1.x installed but loads the repo version

RSpec.describe "Diff::LCS 2.0 with RSpec::Support::Differ" do
  let(:differ) { RSpec::Support::Differ.new }

  it "produces diff output for multiline strings" do
    expected = "foo\nzap\nbar\n"
    actual = "foo\nbar\nzap\n"

    diff = differ.diff(actual, expected)

    expect(diff).to be_a(String)
    expect(diff).not_to be_empty
  end

  it "handles identical strings" do
    str = "same\n"
    diff = differ.diff(str, str)

    # May return empty or just newline depending on implementation
    expect(diff.strip).to be_empty
  end
end
