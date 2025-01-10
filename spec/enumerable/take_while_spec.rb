require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#take_while' do
  it 'calls the block with successive elements as long as the block returns a truthy value; returns an array of all elements up to that point' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.take_while { |i| i < 3 }).to eq([1, 2])
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.take_while).to be_an_instance_of(Enumerator)
    expect(enum.take_while.to_a).to eq([1])
    expect(enum.take_while.each { |i| i < 3 }).to eq([1, 2])
  end

  it 'passes elements to the block until the first false' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    a = []
    enum.take_while { |i| a << i; i < 3 }
    expect(a).to eq([1, 2, 3])
  end

  describe 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.take_while { true }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it 'yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.take_while { |*args| yielded << args; true }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.take_while.size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.take_while.size).to be_nil
        end
      end
    end
  end
end
