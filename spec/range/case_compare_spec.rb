require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#===' do
  # rubocop:disable Style/CaseEquality
  it 'returns true if object is between self.begin and self.end' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    object = RangeSpecs::Element.new(5)
    expect(range.===(object)).to be true
  end

  it 'returns false if object is smaller than self.begin' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    object = RangeSpecs::Element.new(-5)
    expect(range.===(object)).to be false
  end

  it 'returns false if object is greater than self.end' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    object = RangeSpecs::Element.new(10)
    expect(range.===(object)).to be false
  end

  it 'ignores end if excluded end' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6), true)
    object = RangeSpecs::Element.new(6)
    expect(range.===(object)).to be false
  end

  it 'returns true if argument is a single element in the range' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0))
    object = RangeSpecs::Element.new(0)
    expect(range.===(object)).to be true
  end

  it 'returns false if range is empty' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
    object = RangeSpecs::Element.new(0)
    expect(range.===(object)).to be false
  end

  it "returns false if an argument isn't comparable with range boundaries" do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    expect(range.===(Object.new)).to be false
  end

  context 'beginingless range' do
    it 'returns false if object is greater than self.end' do
      range = Range.new(nil, RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(10)
      expect(range.===(object)).to be false
    end

    it 'returns true if object is smaller than self.end' do
      range = Range.new(nil, RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(0)
      expect(range.===(object)).to be true
    end
  end

  context 'endless range' do
    it 'returns true if object is greater than self.begin' do
      range = Range.new(RangeSpecs::Element.new(0), nil)
      object = RangeSpecs::Element.new(10)
      expect(range.===(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = Range.new(RangeSpecs::Element.new(0), nil)
      object = RangeSpecs::Element.new(-10)
      expect(range.===(object)).to be false
    end
  end

  it 'returns true on any value for (nil..nil)' do
    expect(Range.new(nil, nil).===(Object.new)).to be true
  end
  # rubocop:enable Style/CaseEquality
end
