require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#clone" do
  it "duplicates the range" do
    original = (1..3)
    copy = original.clone
    expect(copy.begin).to eq(1)
    expect(copy.end).to eq(3)
    expect(copy.exclude_end?).to be false
    expect(copy).not_to equal(original)

    original = ("a"..."z")
    copy = original.clone
    expect(copy.begin).to eq("a")
    expect(copy.end).to eq("z")
    expect(copy.exclude_end?).to be true
    expect(copy).not_to equal(original)
  end

  it "maintains the frozen state" do
    expect((1..2).clone.frozen?).to eq((1..2).frozen?)
    expect((1..).clone.frozen?).to eq((1..).frozen?)
    expect(Range.new(1, 2).clone.frozen?).to eq(Range.new(1, 2).frozen?)
    expect(Class.new(Range).new(1, 2).clone.frozen?).to eq(Class.new(Range).new(1, 2).frozen?)
  end
end
