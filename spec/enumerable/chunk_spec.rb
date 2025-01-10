require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#chunk' do
  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.chunk).to be_an_instance_of(Enumerator)
    expect(enum.chunk.to_a).to eq([])
    expect(enum.chunk.each { |i| i < 3 }.to_a).to eq([[true, [1, 2]], [false, [3, 4]]])
  end

  it 'returns an Enumerator if given a block' do
    expect(EnumerableSpecs::Numerous.new.chunk {}).to be_an_instance_of(Enumerator)
  end

  it 'yields the current element and the current chunk to the block' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3)
    yielded = []
    e.chunk { |x| yielded << x }.to_a
    expect(yielded).to eq [1, 2, 3]
  end

  it "returns elements of the Enumerable in an Array of Arrays, [v, ary], where 'ary' contains the consecutive elements for which the block returned the value 'v'" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 3, 2, 1)
    result = e.chunk { |x| (x < 3 && 1) || 0 }.to_a
    expect(result).to eq [[1, [1, 2]], [0, [3]], [1, [2]], [0, [3]], [1, [2, 1]]]
  end

  it 'returns a partitioned Array of values' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect(e.chunk { |x| x > 2 }.map(&:last)).to eq [[1, 2], [3]]
  end

  it 'returns elements for which the block returns :_alone in separate Arrays' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 1)
    result = e.chunk { |x| x < 2 && :_alone }.to_a
    expect(result).to eq [[:_alone, [1]], [false, [2, 3, 2]], [:_alone, [1]]]
  end

  it 'yields Arrays as a single argument to a rest argument' do
    e = EnumerableSpecs::Numerous.new([1, 2])
    yielded = []
    e.chunk { |*x| yielded << x }.to_a
    expect(yielded).to eq [[[1, 2]]]
  end

  it 'does not return elements for which the block returns :_separator' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 3, 2, 1)
    result = e.chunk { |x| x == 2 ? :_separator : 1 }.to_a
    expect(result).to eq [[1, [1]], [1, [3, 3]], [1, [1]]]
  end

  it 'does not return elements for which the block returns nil' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 1)
    result = e.chunk { |x| x == 2 ? nil : 1 }.to_a
    expect(result).to eq [[1, [1]], [1, [3]], [1, [1]]]
  end

  it 'raises a RuntimeError if the block returns a Symbol starting with an underscore other than :_alone or :_separator' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 1)
    expect { e.chunk { |_x| :_arbitrary }.to_a }.to raise_error(RuntimeError, 'symbols beginning with an underscore are reserved')
  end

  it 'does not accept arguments' do
    e = EnumerableSpecs::Numerous.new(1, 2, 3)

    expect {
      e.chunk(1) {}
    }.to raise_error(ArgumentError)
  end

  describe 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.chunk { |*args| args.size }.to_a).to eq([[1, [[1, 2], [3, 4, 5], [6, 7, 8, 9]]]])
    end

    it 'yields multiple values as array' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.chunk { |*args| yielded << args }.to_a
      expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.chunk.size).to eq(enum.size)
        end
      end
    end

    context 'when a block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.chunk { true }.size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.chunk.size).to be_nil
        end
      end
    end

    context 'when a block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.chunk { true }.size).to be_nil
        end
      end
    end
  end
end
