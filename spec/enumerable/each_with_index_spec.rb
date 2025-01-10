require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#each_with_index' do
  it 'passes each element and its index to block' do
    enum = EnumerableSpecs::Numerous.new('a', 'b', 'c')
    hash = {}
    enum.each_with_index { |e, i| hash[i] = e }
    expect(hash).to eq({ 0 => 'a', 1 => 'b', 2 => 'c' })
  end

  it 'returns self' do
    enum = EnumerableSpecs::Numerous.new
    expect(enum.each_with_index {}).to equal(enum)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new('a', 'b', 'c')
    expect(enum.each_with_index).to be_an_instance_of(Enumerator)
    expect(enum.each_with_index.to_a).to contain_exactly(['a', 0], ['b', 1], ['c', 2])

    hash = {}
    enum.each_with_index.each { |e, i| hash[i] = e }
    expect(hash).to eq({ 0 => 'a', 1 => 'b', 2 => 'c' })
  end

  it 'passes extra arguments to #each' do
    enum = EnumerableSpecs::EachWithParameters.new

    enum.each_with_index(:foo, :bar) {}
    expect(enum.arguments_passed).to eq(%i[foo bar])

    enum.each_with_index(:foo, :bar).each {}
    expect(enum.arguments_passed).to eq(%i[foo bar])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.each_with_index { |e, _i| yielded << e }
    expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.each_with_index.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.each_with_index.size).to be_nil
        end
      end
    end
  end
end
