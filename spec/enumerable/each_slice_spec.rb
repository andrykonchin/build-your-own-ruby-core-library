require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#each_slice' do
  it 'calls the block with each successive disjoint n-tuple of elements' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5)
    slices = []
    enum.each_slice(2) { |s| slices << s }
    expect(slices).to contain_exactly([1, 2], [3, 4], [5])
  end

  it 'returns self' do
    enum = EnumerableSpecs::Numerous.new
    expect(enum.each_slice(2) {}).to equal(enum)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5)
    expect(enum.each_slice(2)).to be_an_instance_of(Enumerator)
    expect(enum.each_slice(2).to_a).to contain_exactly([1, 2], [3, 4], [5])

    slices = []
    enum.each_slice(2).each { |s| slices << s }
    expect(slices).to contain_exactly([1, 2], [3, 4], [5])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.each_slice(2) { |s| yielded << s }
    expect(yielded).to contain_exactly([[1, 2], [3, 4, 5]], [[6, 7, 8, 9]])
  end

  it 'returns a single slice containing all elements when the argument greater than enumerable size' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5)
    slices = []
    enum.each_slice(100) { |s| slices << s }
    expect(slices).to eq([[1, 2, 3, 4, 5]])
  end

  it 'returns no slices when enumerable is empty' do
    enum = EnumerableSpecs::Empty.new
    slices = []
    enum.each_slice(100) { |s| slices << s }
    expect(slices).to eq([])
  end

  it 'raises ArgumentError when an argument is negative' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.each_slice(-2)
    }.to raise_error(ArgumentError, 'invalid slice size')
  end

  it 'raises ArgumentError when an argument is 0' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.each_slice(0)
    }.to raise_error(ArgumentError, 'invalid slice size')
  end

  it 'raises a RangeError when passed a Bignum' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.each_slice(bignum_value)
    }.to raise_error(RangeError, "bignum too big to convert into 'long'")
  end

  describe 'argument conversion to Integer' do
    it 'converts the passed argument to an Integer using #to_int' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5)
      n = double('n', to_int: 2)
      slices = []
      enum.each_slice(n) { |s| slices << s }
      expect(slices).to contain_exactly([1, 2], [3, 4], [5])
    end

    it 'raises a TypeError if the passed argument does not respond to #to_int' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.each_slice(nil) {} }.to raise_error(TypeError, 'no implicit conversion from nil to integer')
      expect { enum.each_slice('a') {} }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
    end

    it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
      enum = EnumerableSpecs::Numerous.new
      n = double('n', to_int: 'a')

      expect {
        enum.each_slice(n) {}
      }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enum size / each_slice argument' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4, 5)
          expect(enum.each_slice(1).size).to eq(5)
          expect(enum.each_slice(2).size).to eq(3)
          expect(enum.each_slice(3).size).to eq(2)
          expect(enum.each_slice(4).size).to eq(2)
          expect(enum.each_slice(5).size).to eq(1)
        end

        it 'size returns 1 when the argument is larger than enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3)
          expect(enum.each_slice(20).size).to eq(1)
        end

        it 'size returns 0 when the enumerable is empty' do
          enum = EnumerableSpecs::EmptyWithSize.new
          expect(enum.each_slice(10).size).to eq(0)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.each_slice(8).size).to be_nil
        end
      end
    end
  end
end
