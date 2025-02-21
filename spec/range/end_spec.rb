require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#end' do
  it 'returns the object that defines the end of a range' do
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)
    range = Range.new(a, b)
    expect(range.end).to equal(b)
  end

  it 'returns nil for an endless range' do
    a = RangeSpecs::Element.new(0)
    range = Range.new(a, nil)
    expect(range.end).to be_nil
  end

  it 'returns declared end of a range even if end is excluded' do
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)
    range = Range.new(a, b, true)
    expect(range.end).to equal(b)
  end
end
