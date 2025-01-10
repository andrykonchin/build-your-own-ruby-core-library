require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#each_with_object' do
  it 'calls the block once for each element, passing both the element and the given object' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    object = []
    enum.each_with_object(object) { |e, memo| memo.unshift(e) }
    expect(object).to eq([4, 3, 2, 1])
  end

  it 'returns the object' do
    enum = EnumerableSpecs::Numerous.new
    object = Object.new
    expect(enum.each_with_object(object) {}).to equal(object)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    object = Object.new
    expect(enum.each_with_object(object)).to be_an_instance_of(Enumerator)
    expect(enum.each_with_object(object).to_a).to eq([[1, object], [2, object], [3, object], [4, object]])
    expect(enum.each_with_object(object).each {}).to equal(object)
  end

  it 'ignores a value returned from a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    object = []
    enum.each_with_object(object) { |e, memo| memo.unshift(e); nil }
    expect(object).to eq([4, 3, 2, 1])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.each_with_object(Object.new) { |e, _memo| yielded << e }
    expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.each_with_object([]).size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.each_with_object([]).size).to be_nil
        end
      end
    end
  end
end
