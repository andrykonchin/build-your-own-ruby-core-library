require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#sum' do
  it 'returns the sum of initial value and the elements' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.sum(1)).to eq(1 + 1 + 2 + 3 + 4)

    enum = EnumerableSpecs::Numerous.new('b', 'c', 'd', 'e')
    expect(enum.sum('a')).to eq('abcde')
  end

  it 'uses 0 as an initial argument if given no argument' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.sum).to eq(1 + 2 + 3 + 4)
  end

  context 'given a block' do
    it 'returns the sum of initial value and the block return values' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.sum(1) { |e| e * 10 }).to eq(1 + 10 + 20 + 30 + 40)
    end

    it 'yields multiple arguments as array when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.sum { |*args| yielded << args; 0 }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end
end
