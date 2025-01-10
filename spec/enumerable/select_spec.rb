require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#select' do
  it 'returns all elements for which the block is not false' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.select { |i| i < 3 }).to contain_exactly(1, 2)
  end

  it 'returns an enumerator when no block given' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.select).to be_an_instance_of(Enumerator)
    expect(enum.select.to_a).to contain_exactly(1, 2, 3, 4)
    expect(enum.select.each { |e| e < 3 }).to contain_exactly(1, 2)
  end

  describe 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.select { true }).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end

    it 'yields multiple values as array' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.select { |*args| yielded << args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.select.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.select.size).to be_nil
        end
      end
    end
  end
end
