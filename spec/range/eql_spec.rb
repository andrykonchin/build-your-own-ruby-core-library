require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#eql?' do
  it 'returns true if and only if other is a Range, self.begin and self.end are equal with #eql? and exclude_end is the same' do
    a = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)
    b = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)

    expect(a).to eql(b)
  end

  it "returns false if other isn't a Range" do
    expect(Range.new(0, 6)).not_to eql(Object.new)
  end

  it "returns false if self.begin values aren't equal with #eql?" do
    a = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)
    b = Range.new(RangeSpecs::WithEql.new(1), RangeSpecs::WithEql.new(6), true)

    expect(a).not_to eql(b)
  end

  it "returns false if self.end values aren't equal with #eql?" do
    a = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)
    b = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(7), true)

    expect(a).not_to eql(b)
  end

  it "returns false if exclude_end? values aren't the same" do
    a = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)
    b = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), false)

    expect(a).not_to eql(b)
  end

  it 'returns true if other is an instance of a Range subclass' do
    subclass = Class.new(Range)
    a = Range.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)
    b = subclass.new(RangeSpecs::WithEql.new(0), RangeSpecs::WithEql.new(6), true)

    expect(a).to eql(b)
  end

  it 'returns true for endless Ranges with equal self.begin' do
    a = Range.new(RangeSpecs::WithEql.new(0), nil, true)
    b = Range.new(RangeSpecs::WithEql.new(0), nil, true)
    expect(a).to eql(b)

    a = Range.new(RangeSpecs::WithEql.new(0), nil, false)
    b = Range.new(RangeSpecs::WithEql.new(0), nil, false)
    expect(a).to eql(b)
  end

  it 'returns false for endless Ranges with not equal self.begin' do
    a = Range.new(RangeSpecs::WithEql.new(0), nil, true)
    b = Range.new(RangeSpecs::WithEql.new(1), nil, true)
    expect(a).not_to eql(b)
  end

  it 'returns false for endless Ranges with not equal exclude_end?' do
    a = Range.new(RangeSpecs::WithEql.new(0), nil, true)
    b = Range.new(RangeSpecs::WithEql.new(0), nil, false)
    expect(a).not_to eql(b)
  end

  it 'returns true for beginingless Ranges with equal self.end' do
    a = Range.new(nil, RangeSpecs::WithEql.new(0), true)
    b = Range.new(nil, RangeSpecs::WithEql.new(0), true)
    expect(a).to eql(b)

    a = Range.new(nil, RangeSpecs::WithEql.new(0), false)
    b = Range.new(nil, RangeSpecs::WithEql.new(0), false)
    expect(a).to eql(b)
  end

  it 'returns false for beginingless Ranges with not equal self.end' do
    a = Range.new(nil, RangeSpecs::WithEql.new(0), true)
    b = Range.new(nil, RangeSpecs::WithEql.new(1), true)
    expect(a).not_to eql(b)
  end

  it 'returns false for beginingless Ranges with not equal exclude_end?' do
    a = Range.new(nil, RangeSpecs::WithEql.new(0), true)
    b = Range.new(nil, RangeSpecs::WithEql.new(0), false)
    expect(a).not_to eql(b)
  end
end
