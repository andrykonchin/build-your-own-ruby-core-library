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

RSpec.describe 'Enumerable#min' do
  it 'returns the minimum element' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.min).to eq(1)
  end

  it 'compares elements with #<=> method' do
    a, b, c = (1..3).map { |n| EnumerableSpecs::ReverseComparable.new(n) }
    enum = EnumerableSpecs::Numerous.new(a, b, c)
    expect(enum.min).to eq(c)
  end

  it 'returns nil for an empty Enumerable' do
    expect(EnumerableSpecs::Empty.new.min).to be_nil
  end

  it 'raises a NoMethodError for elements not responding to #<=>' do
    enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new)

    expect {
      enum.min
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it 'raises an ArgumentError for incomparable elements' do
    enum = EnumerableSpecs::Numerous.new(11, '22')

    expect {
      enum.min
    }.to raise_error(ArgumentError, 'comparison of String with 11 failed')
  end

  context 'given an argument n' do
    it 'returns an array containing n smallest elements' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min(2)).to contain_exactly(1, 2)
    end

    it 'ignores nil value' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min(nil)).to eq(1)
    end

    it 'allows an argument n be greater than elements number' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min(10)).to contain_exactly(1, 2, 3, 4)
    end

    it 'raises an ArgumentError when n is negative' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.min(-1) }.to raise_error(ArgumentError, 'negative size (-1)')
    end

    it 'raises a RangeError when passed a Bignum' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.min(bignum_value)
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        n = double('n', to_int: 2)
        expect(enum.min(n)).to contain_exactly(1, 2)
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        enum = EnumerableSpecs::Numerous.new
        expect { enum.min('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        enum = EnumerableSpecs::Numerous.new
        n = double('n', to_int: 'a')

        expect {
          enum.min(n)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end

  context 'given a block' do
    it 'compares elements using a block' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min { |a, b| b <=> a }).to eq(4)
    end

    it 'returns an array containing the minimum n elements when called with an argument n' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min(2) { |a, b| b <=> a }).to contain_exactly(4, 3)
    end

    context 'when #each yields multiple' do
      it 'gathers whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        expect(multi.min { |a, b| a <=> b }).to eq([1, 2])
      end

      it 'yields whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        yielded = Set.new
        multi.min { |*args| yielded += args; 0 }
        expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
      end
    end
  end
end
