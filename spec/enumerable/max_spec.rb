require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#max' do
  it 'returns the maximum element' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.max).to eq(4)
  end

  it 'compares elements with #<=> method' do
    a, b, c = (1..3).map { |n| EnumerableSpecs::ReverseComparable.new(n) }
    enum = EnumerableSpecs::Numerous.new(a, b, c)
    expect(enum.max).to eq(a)
  end

  it 'returns nil for an empty Enumerable' do
    expect(EnumerableSpecs::Empty.new.max).to be_nil
  end

  it 'raises a NoMethodError for elements not responding to #<=>' do
    enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new)

    expect {
      enum.max
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it 'raises an ArgumentError for incomparable elements' do
    enum = EnumerableSpecs::Numerous.new(11, '22')

    expect {
      enum.max
    }.to raise_error(ArgumentError, 'comparison of String with 11 failed')
  end

  context 'given an argument' do
    it 'returns an array containing n greatest elements' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max(2)).to contain_exactly(3, 4)
    end

    it 'ignores nil value' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max(nil)).to eq(4)
    end

    it 'allows an argument n be greater than elements number' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max(10)).to contain_exactly(1, 2, 3, 4)
    end

    it 'raises an ArgumentError when n is negative' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.max(-1) }.to raise_error(ArgumentError, 'negative size (-1)')
    end

    it 'raises a RangeError when passed a Bignum' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.max(bignum_value)
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        n = double('n', to_int: 2)
        expect(enum.max(n)).to contain_exactly(3, 4)
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        enum = EnumerableSpecs::Numerous.new
        expect { enum.max('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        enum = EnumerableSpecs::Numerous.new
        n = double('n', to_int: 'a')

        expect {
          enum.max(n)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end

  context 'given a block' do
    it 'compares elements using a block' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max { |a, b| b <=> a }).to eq(1)
    end

    it 'returns an array containing the maximum n elements when called with an argument n' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max(2) { |a, b| b <=> a }).to contain_exactly(2, 1)
    end

    context 'when #each yields multiple' do
      it 'gathers whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        expect(multi.max { |a, b| a <=> b }).to eq([6, 7, 8, 9])
      end

      it 'yields whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        yielded = Set.new
        multi.max { |*args| yielded += args; 0 }
        expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
      end
    end
  end
end
