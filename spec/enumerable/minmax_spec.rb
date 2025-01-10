require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#minmax' do
  it 'returns a 2-element array containing the minimum and the maximum elements' do
    enum = EnumerableSpecs::Numerous.new(6, 4, 5, 10, 8)
    expect(enum.minmax).to eq([4, 10])
  end

  it 'compares elements with #<=> method' do
    a = double('a', value: 'a')
    def a.<=>(o); value <=> o.value; end

    b = double('b', value: 'b')
    def b.<=>(o); value <=> o.value; end

    c = double('c', value: 'c')
    def c.<=>(o); value <=> o.value; end

    expect(EnumerableSpecs::Numerous.new(a, c, b).minmax).to eq([a, c])
  end

  it 'compares elements using a block when it is given' do
    enum = EnumerableSpecs::Numerous.new(6, 4, 5, 10, 8)
    expect(enum.minmax { |a, b| b <=> a }).to eq([10, 4])
  end

  it 'returns [nil, nil] for an empty Enumerable' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.minmax).to eq([nil, nil])
  end

  it 'returns [element, element] for an Enumerable with only one element' do
    enum = EnumerableSpecs::Numerous.new(1)
    expect(enum.minmax).to eq([1, 1])
  end

  it 'raises a NoMethodError for elements not responding to #<=>' do
    enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new)

    expect {
      enum.minmax
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it 'raises an ArgumentError when elements are incompatible' do
    enum = EnumerableSpecs::Numerous.new(11, '22')

    expect {
      enum.minmax
    }.to raise_error(ArgumentError, 'comparison of Integer with String failed')
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.minmax).to eq([[1, 2], [6, 7, 8, 9]])
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = Set.new
      multi.minmax { |*args| yielded += args; 0 }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end
end
