require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#dup" do
  it "duplicates the range" do
    original = (1..3)
    copy = original.dup
    expect(copy.begin).to eq(1)
    expect(copy.end).to eq(3)
    expect(copy.exclude_end?).to be false
    expect(copy).not_to equal(original)

    copy = ("a"..."z").dup
    expect(copy.begin).to eq("a")
    expect(copy.end).to eq("z")
    expect(copy.exclude_end?).to be true
  end

  it "creates an unfrozen range" do
    expect((1..2).dup.frozen?).to be false
    expect((1..).dup.frozen?).to be false
    expect(Range.new(1, 2).dup.frozen?).to be false
  end
end
