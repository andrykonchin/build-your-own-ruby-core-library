require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#to_a' do
  it 'returns an array containing elements of self' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.to_a).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      ]
    )
  end

  it "doesn't yield the last element if excluded end" do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    expect(range.to_a).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3)
      ]
    )
  end

  it 'returns an empty array if backward range' do
    range = Range.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
    expect(range.to_a).to eq([])
  end

  it 'raises RangeError if endless range' do
    range = Range.new(RangeSpecs::WithSucc.new(1), nil)

    expect {
      range.to_a
    }.to raise_error(RangeError, 'cannot convert endless range to an array')
  end

  it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
    range = Range.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))
    expect {
      range.size
    }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")

    range = Range.new(nil, RangeSpecs::WithoutSucc.new(4))
    expect {
      range.size
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end
end
