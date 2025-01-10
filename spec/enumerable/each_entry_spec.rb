require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#each_entry' do
  it 'calls the given block with each element' do
    yielded = []

    EnumerableSpecs::Numerous.new(1, 2, 3, 4).each_entry do |e|
      yielded << e
    end

    expect(yielded).to eq([1, 2, 3, 4])
  end

  it 'returns self' do
    enum = EnumerableSpecs::Numerous.new
    expect(enum.each_entry {}).to equal(enum)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.each_entry).to be_an_instance_of(Enumerator)
    expect(enum.each_entry.to_a).to eq([1, 2, 3, 4])

    yielded = []
    expect(enum.each_entry.each { |e| yielded << e }).to eq(enum)
    expect(yielded).to eq([1, 2, 3, 4])
  end

  it 'raises an ArgumentError when extra arguments' do
    expect { EnumerableSpecs::Numerous.new.each_entry('one').to_a }.to raise_error(ArgumentError)
    expect { EnumerableSpecs::Numerous.new.each_entry('one') {}.to_a }.to raise_error(ArgumentError)
  end

  it 'passes extra arguments to #each' do
    enum = EnumerableSpecs::EachWithParameters.new(1, 2)
    expect(enum.each_entry(:foo, 'bar').to_a).to eq([1, 2])
    expect(enum.arguments_passed).to eq([:foo, 'bar'])
  end

  it 'yields multiple values as array when #each yields multiple values' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.each_entry { |*args| yielded << args }
    expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.each_entry.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.each_entry.size).to be_nil
        end
      end
    end
  end
end
