# frozen_string_literal: true

RSpec.describe "Hash diff failure" do
  it "shows diff for nested hash mismatch" do
    expected = {
      name: "John",
      age: 30,
      address: {
        city: "New York",
        zip: "10001"
      }
    }

    actual = {
      name: "John",
      age: 35,
      address: {
        city: "Boston",
        zip: "10001"
      }
    }

    expect(actual).to eq(expected)
  end
end
