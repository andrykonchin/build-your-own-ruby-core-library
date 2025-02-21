require 'spec_helper'
require_relative 'fixtures/classes'

# There is no Range#frozen? method but this feels like the best place for these specs
RSpec.describe "Range#frozen?" do
  it "is true for literal ranges" do
    expect((1..2).frozen?).to be true
    expect((1..).frozen?).to be true
    expect((..1).frozen?).to be true
  end

  it "is true for Range.new" do
    expect(Range.new(1, 2).frozen?).to be true
    expect(Range.new(1, nil).frozen?).to be true
    expect(Range.new(nil, 1).frozen?).to be true
  end

  it "is false for instances of a subclass of Range" do
    sub_range = Class.new(Range).new(1, 2)
    expect(sub_range.frozen?).to be false
  end

  it "is false for Range.allocate" do
    expect(Range.allocate.frozen?).to be false
  end
end
