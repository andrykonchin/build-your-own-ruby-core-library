require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range.new" do
  it "constructs a range using the given start and end" do
    range = Range.new(0, 1)

    expect(range.begin).to eq(0)
    expect(range.end).to eq(1)
  end

  it "includes the end object when the third parameter is omitted" do
    range = Range.new(0, 1)
    expect(range.exclude_end?).to be false
  end

  it "excludes end when the third parameter is a truthy value" do
    expect(Range.new(0, 1, true).exclude_end?).to be true
    expect(Range.new(0, 1, Object.new).exclude_end?).to be true
    expect(Range.new(0, 1, "a").exclude_end?).to be true
  end

  it "includes end when the third parameter is a falsy value" do
    expect(Range.new(0, 1, nil).exclude_end?).to be false
    expect(Range.new(0, 1, false).exclude_end?).to be false
  end

  it "raises an ArgumentError if start or end doesn't respond to #<=>" do
    expect {
      Range.new(Object.new, 1)
    }.to raise_error(ArgumentError, "bad value for range")

    expect {
      Range.new(0, Object.new)
    }.to raise_error(ArgumentError, "bad value for range")
  end

  it "raises an ArgumentError if start and end respond to #<=> but aren't comparable" do
    a = double("begin", "<=>": nil)
    b = double("end", "<=>": nil)

    expect {
      Range.new(a, b)
    }.to raise_error(ArgumentError, "bad value for range")
  end

  describe "beginless/endless range" do
    it "allows beginless left boundary" do
      range = Range.new(nil, 1)
      expect(range.begin).to be nil
    end

    it "allows endless right boundary" do
      range = Range.new(1, nil)
      expect(range.end).to be nil
    end
  end

  it "creates a frozen range if the class is Range.class" do
    expect(Range.new(1, 2).frozen?).to be true
  end

  it "does not create a frozen range if the class is not Range.class" do
    expect(Class.new(Range).new(1, 2).frozen?).to be false
  end
end
