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

RSpec.describe 'Enumerable#drop' do
  it 'returns an array containing all but the first n elements' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.drop(2)).to eq([3, 4])
  end

  it 'raises ArgumentError if n is negative' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.drop(-1)
    }.to raise_error(ArgumentError, 'attempt to drop negative size')
  end

  it 'returns all elements if n is 0' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.drop(0)).to eq([1, 2, 3, 4])
  end

  it 'raises a RangeError when passed a Bignum' do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.drop(bignum_value)
    }.to raise_error(RangeError, "bignum too big to convert into 'long'")
  end

  it 'returns [] for empty enumerables' do
    expect(EnumerableSpecs::Empty.new.drop(2)).to eq([])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.drop(2)).to eq([[6, 7, 8, 9]])
  end

  describe 'argument conversion to Integer' do
    it 'converts the passed argument to an Integer using #to_int' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      n = double('n', to_int: 2)
      expect(enum.drop(n)).to eq([3, 4])
    end

    it 'raises a TypeError if the passed argument does not respond to #to_int' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.drop(nil) }.to raise_error(TypeError, 'no implicit conversion from nil to integer')
      expect { enum.drop('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
    end

    it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
      enum = EnumerableSpecs::Numerous.new
      obj = double('n', to_int: 'a')

      expect {
        enum.drop(obj)
      }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
    end
  end
end
