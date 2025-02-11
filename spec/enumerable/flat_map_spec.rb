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

RSpec.describe 'Enumerable#flat_map' do
  it 'returns an array of flattened objects returned by the block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.flat_map { |n| [n, -n] }).to contain_exactly(1, -1, 2, -2, 3, -3, 4, -4)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.flat_map).to be_an_instance_of(Enumerator)
    expect(enum.flat_map.to_a).to contain_exactly(1, 2, 3, 4)
    expect(enum.flat_map.each { |i| [i] * i }).to contain_exactly(1, 2, 2, 3, 3, 3, 4, 4, 4, 4)
  end

  it 'flattens one level only' do
    enum = EnumerableSpecs::Numerous.new(1, [2, 3], [4, [5, 6]], [7, [8, [9]]])
    expect(enum.flat_map { |i| i }).to contain_exactly(1, 2, 3, 4, [5, 6], 7, [8, [9]])
  end

  it 'appends non-Array elements that do not define #to_ary' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.flat_map { |i| i }).to contain_exactly(1, 2, 3, 4)
  end

  it 'appends non-Array elements that responds to #to_ary but it returns nil' do
    obj = double('array', to_ary: nil)
    enum = EnumerableSpecs::Numerous.new(obj)
    expect(enum.flat_map { |i| i }).to contain_exactly(obj)
  end

  it 'yields multiple values when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.flat_map { |*args| yielded << args }
    expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
  end

  context 'elements conversion to Array' do
    it 'converts non-Array elements that respond to #to_ary to Arrays' do
      obj = double('array', to_ary: [1, 2, 3, 4])
      enum = EnumerableSpecs::Numerous.new(obj)
      expect(enum.flat_map { |i| i }).to contain_exactly(1, 2, 3, 4)
    end

    it 'raises TypeError if an element responds to #to_ary and it does not return an Array or nil' do
      obj = double('array', to_ary: {})
      enum = EnumerableSpecs::Numerous.new(obj)
      expect { enum.flat_map { |i| i } }.to raise_error(TypeError)
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.flat_map.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.flat_map.size).to be_nil
        end
      end
    end
  end
end
