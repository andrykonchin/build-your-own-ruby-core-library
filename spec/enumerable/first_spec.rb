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

RSpec.describe 'Enumerable#first' do
  it 'returns the first element' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.first).to eq(1)
  end

  it 'returns nil if self is empty' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.first).to be_nil
  end

  it 'gathers whole arrays as elements when #each yields multiple values' do
    enum = EnumerableSpecs::YieldsMulti.new
    expect(enum.first).to eq([1, 2])
  end

  describe 'when passed an argument' do
    it 'returns the first n elements' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.first(2)).to eq([1, 2])
    end

    it 'returns an empty array when enumerable is empty' do
      empty = EnumerableSpecs::Empty.new
      expect(empty.first(2)).to eq([])
    end

    it 'returns an empty array when n is zero' do
      enum = EnumerableSpecs::Numerous.new
      expect(enum.first(0)).to eq([])
    end

    it 'raises an ArgumentError when an argument is negative' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.first(-1)
      }.to raise_error(ArgumentError, 'attempt to take negative size')
    end

    it 'raises a RangeError when passed a Bignum' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.first(bignum_value)
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    it 'returns the entire array when an argument > enum size' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.first(100)).to eq([1, 2, 3, 4])
    end

    it 'gathers whole arrays as elements when #each yields multiple' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.first(1)).to eq([[1, 2]])
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        n = double('n', to_int: 2)
        expect(enum.first(n)).to eq([1, 2])
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        enum = EnumerableSpecs::Numerous.new
        expect { enum.first(nil) }.to raise_error(TypeError, 'no implicit conversion from nil to integer')
        expect { enum.first('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        enum = EnumerableSpecs::Numerous.new
        n = double('n', to_int: 'a')

        expect {
          enum.first(n)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end
end
