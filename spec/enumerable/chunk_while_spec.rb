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

RSpec.describe 'Enumerable#chunk_while' do
  context 'given a block' do
    it 'returns an enumerator' do
      enum = EnumerableSpecs::Numerous.new
      expect(enum.chunk_while { |_i, _j| true }).to be_an_instance_of(Enumerator)
    end

    it 'yields each element with the next one' do
      enum = EnumerableSpecs::Numerous.new(10, 9, 7, 6, 4, 3, 2, 1)
      yielded = []
      enum.chunk_while { |i, j| yielded << [i, j]; i - 1 == j }.to_a
      expect(yielded).to eq([[10, 9], [9, 7], [7, 6], [6, 4], [4, 3], [3, 2], [2, 1]])
    end

    it 'splits chunks between adjacent elements i and j where the block returns false' do
      enum = EnumerableSpecs::Numerous.new(10, 9, 7, 6, 4, 3, 2, 1)
      result = enum.chunk_while { |i, j| i - 1 == j }
      expect(result.to_a).to eq([[10, 9], [7, 6], [4, 3, 2, 1]])
    end

    it 'calls the block for length of the receiver enumerable minus one times' do
      array = [10, 9, 7, 6, 4, 3, 2, 1]
      enum = EnumerableSpecs::Numerous.new(*array)
      enum_length = array.length

      times_called = 0
      enum.chunk_while do |i, j|
        times_called += 1
        i - 1 == j
      end.to_a
      expect(times_called).to eq(enum_length - 1)
    end
  end

  context 'given no block' do
    it 'raises an ArgumentError' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.chunk_while }.to raise_error(ArgumentError, 'tried to create Proc object without a block')
    end
  end

  context 'single-element enumerable' do
    it 'ignores the block and returns an enumerator that yields [element]' do
      enum = EnumerableSpecs::Numerous.new(1)
      expect(enum.chunk_while { |x| x.even? }.to_a).to eq [[1]]
    end
  end

  context 'empty enumerable' do
    it 'returns an empty enumerator' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.chunk_while { |x| x.even? }.to_a).to eq []
    end
  end

  describe 'when #each yields multiple values' do
    it 'yields multiple values as array' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.chunk_while { |*args| yielded << args; true }.to_a
      expect(yielded).to eq([[[1, 2], [3, 4, 5]], [[3, 4, 5], [6, 7, 8, 9]]])
    end

    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      result = multi.chunk_while { |*args| args[0].length.even? }.to_a
      expect(result).to eq([[[1, 2], [3, 4, 5]], [[6, 7, 8, 9]]])
    end
  end

  describe 'Enumerable with size' do
    context 'when a block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.chunk_while {}.size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    context 'when a block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.chunk_while {}.size).to be_nil
        end
      end
    end
  end
end
