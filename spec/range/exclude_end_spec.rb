require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#exclude_end?" do
  it "returns false if the range does not exclude the end value" do
    expect((-2..2).exclude_end?).to be false
    expect(('A'..'B').exclude_end?).to be false
    expect((0.5..2.4).exclude_end?).to be false
    expect((0xfffd..0xffff).exclude_end?).to be false
    expect(Range.new(0, 1).exclude_end?).to be false
  end

  it "returns true if the range excludes the end value" do
    expect((0...5).exclude_end?).to be true
    expect(('A'...'B').exclude_end?).to be true
    expect((0.5...2.4).exclude_end?).to be true
    expect((0xfffd...0xffff).exclude_end?).to be true
    expect(Range.new(0, 1, true).exclude_end?).to be true
  end
end
