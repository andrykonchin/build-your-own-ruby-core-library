# Copyright (c) 2025 Andrii Konchyn
# Copyright (c) 2008 Engine Yard, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#max_by' do
  it 'returns element for which the block returns the maximum value' do
    enum = EnumerableSpecs::Numerous.new(*%w[4 3 2 1])
    expect(enum.max_by { |e| e.to_i }).to eq('4')
  end

  it 'compares returned by a block values with #<=> method' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect(enum.max_by { |e| EnumerableSpecs::ReverseComparable.new(e) }).to eq(1)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(4, 3, 2, 1)
    expect(enum.max_by).to be_an_instance_of(Enumerator)
    expect(enum.max_by.to_a).to contain_exactly(4, 3, 2, 1)
    expect(enum.max_by.each { |e| e }).to eq(4) # rubocop:disable Lint/Void
  end

  it 'returns nil for an empty Enumerable' do
    expect(EnumerableSpecs::Empty.new.max_by { 1 }).to be_nil
  end

  it 'raises a NoMethodError for returned by a block values not responding to #<=>' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.max_by { BasicObject.new }
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it 'raises an ArgumentError for incomparable for returned by a block values' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.max_by { EnumerableSpecs::Uncomparable.new }
    }.to raise_error(ArgumentError, 'comparison of EnumerableSpecs::Uncomparable with EnumerableSpecs::Uncomparable failed')
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.max_by { |e| e }).to eq([6, 7, 8, 9])
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.max_by { |*args| yielded << args; args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  context 'given an argument n' do
    it 'returns an array containing n elements for which a block returned the maximum values' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max_by(2) { |e| e }).to contain_exactly(3, 4)
    end

    it 'returns an Enumerator if called without a block' do
      enum = EnumerableSpecs::Numerous.new(4, 3, 2, 1)
      expect(enum.max_by(2)).to be_an_instance_of(Enumerator)
      expect(enum.max_by(2).to_a).to contain_exactly(4, 3, 2, 1)
      expect(enum.max_by(2).each { |e| e }).to contain_exactly(3, 4) # rubocop:disable Lint/Void
    end

    it 'ignores nil value' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max_by(nil) { |e| e }).to eq(4)
    end

    it 'allows an argument n be greater than elements number' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.max_by(10) { |e| e }).to contain_exactly(1, 2, 3, 4)
    end

    it 'raises an ArgumentError when n is negative' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.max_by(-1) { |e| e } }.to raise_error(ArgumentError, 'negative size (-1)')
    end

    it 'raises a RangeError when passed a Bignum' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.max_by(bignum_value) { |e| e }
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        n = double('n', to_int: 2)
        expect(enum.max_by(n) { |e| e }).to contain_exactly(3, 4)
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        enum = EnumerableSpecs::Numerous.new

        expect {
          enum.max_by('a') { |e| e }
        }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        enum = EnumerableSpecs::Numerous.new
        n = double('n', to_int: 'a')

        expect {
          enum.max_by(n) { |e| e }
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.max_by.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.max_by.size).to be_nil
        end
      end
    end
  end
end
