# frozen_string_literal: true

RSpec.describe "String diff failure" do
  it "shows diff for multiline string mismatch" do
    expected = "line1\nline2\nline3\nline4\nline5\n"
    actual = "line1\nchanged\nline3\nline4\nline5\n"

    expect(actual).to eq(expected)
  end
end
