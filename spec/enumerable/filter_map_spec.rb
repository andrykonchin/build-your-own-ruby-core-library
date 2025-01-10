require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#filter_map' do
  it 'returns an array containing truthy elements returned by the block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.filter_map { |i| i * 2 if i.even? }).to eq([4, 8])
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.filter_map).to be_an_instance_of(Enumerator)
    expect(enum.filter_map.to_a).to eq([1, 2, 3, 4])
    expect(enum.filter_map.each { |i| i * 2 if i.even? }).to eq([4, 8])
  end

  it 'yields multiple arguments when #each yields multiple values' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.filter_map { |*args| yielded << args }
    expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.filter_map.size).to eq(4)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.filter_map.size).to be_nil
        end
      end
    end
  end
end
