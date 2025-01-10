require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#reject' do
  it 'returns an array of the elements for which block is false' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.reject { |i| i < 3 }).to contain_exactly(3, 4)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.reject).to be_an_instance_of(Enumerator)
    expect(enum.reject.to_a).to contain_exactly(1, 2, 3, 4)
    expect(enum.reject.each { |i| i < 3 }).to contain_exactly(3, 4)
  end

  describe 'when #each yields multiple values' do
    it 'yields multiple values as array' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.reject { |*args| yielded << args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'gathers multiple values as array' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.reject { false }).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.reject.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.reject.size).to be_nil
        end
      end
    end
  end
end
