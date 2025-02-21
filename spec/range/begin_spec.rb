require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#begin' do
  it 'returns the object that defines the beginning of a range' do
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)
    range = Range.new(a, b)
    expect(range.begin).to equal(a)
  end

  it 'returns nil for a beginningless range' do
    a = RangeSpecs::Element.new(0)
    range = Range.new(nil, a)
    expect(range.begin).to be_nil
  end
end
