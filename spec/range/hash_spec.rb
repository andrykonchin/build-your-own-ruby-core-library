require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#hash' do
  it 'returns an Integer' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    expect(range.hash).to be_an_instance_of(Integer)
  end

  it 'returns different values for different ranges' do
    a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    b = Range.new(RangeSpecs::Element.new(-1), RangeSpecs::Element.new(1))
    expect(a.hash).not_to eq(b.hash)
  end

  it 'returns the same values for ranges with the same self.begin, self.end and exclude_end? values' do
    from = RangeSpecs::Element.new(0)
    to = RangeSpecs::Element.new(6)

    a = Range.new(from, to)
    b = Range.new(from, to)

    expect(a.hash).to eq(b.hash)
  end
end
