require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#partition' do
  it 'returns two arrays, the first containing elements for which the block returns a truthy value, the second containing the rest' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.partition { |i| i.even? }).to eq([[2, 4], [1, 3]])
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.partition).to be_an_instance_of(Enumerator)
    expect(enum.partition.to_a).to eq([1, 2, 3, 4])
    expect(enum.partition.each { |i| i.even? }).to eq([[2, 4], [1, 3]])
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.partition { true }).to eq([[[1, 2], [3, 4, 5], [6, 7, 8, 9]], []])
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.partition { |*args| yielded << args; false }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.partition.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.partition.size).to be_nil
        end
      end
    end
  end
end
