require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#clone' do
  it 'duplicates a range' do
    range = Range.new(1, 3)
    copy = range.clone

    expect(copy.begin).to eq(1)
    expect(copy.end).to eq(3)
  end

  it 'returns a new object' do
    range = Range.new(1, 3)
    copy = range.clone
    expect(copy).not_to equal(range)
  end

  it 'reuses boundary objects' do
    a = RangeSpecs::Element.new(1)
    b = RangeSpecs::Element.new(3)
    range = Range.new(a, b)
    copy = range.clone

    expect(copy.begin).to equal(a)
    expect(copy.end).to equal(b)
  end

  it 'preserves self.exclude_end?' do
    range = Range.new(1, 3, true)
    copy = range.clone
    expect(copy.exclude_end?).to be true

    range = Range.new(1, 3, false)
    copy = range.clone
    expect(copy.exclude_end?).to be false
  end

  it 'returns a frozen object' do
    range = Range.new(1, 3)
    copy = range.clone
    expect(copy.frozen?).not_to be false
  end
end
