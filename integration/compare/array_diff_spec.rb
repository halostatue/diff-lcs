# frozen_string_literal: true

RSpec.describe "Array diff failure" do
  it "shows diff for array with different elements" do
    expected = ["apple", "banana", "cherry", "date", "elderberry"]
    actual = ["apple", "blueberry", "cherry", "date", "elderberry"]

    expect(actual).to eq(expected)
  end
end
