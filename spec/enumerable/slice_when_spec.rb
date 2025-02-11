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

RSpec.describe 'Enumerable#slice_when' do
  context 'when given a block' do
    it 'returns an enumerator' do
      enum = EnumerableSpecs::Numerous.new
      expect(enum.slice_when { true }).to be_an_instance_of(Enumerator)
    end

    it 'yields each element with the next one' do
      enum = EnumerableSpecs::Numerous.new(10, 9, 7, 6, 4, 3, 2, 1)
      yielded = []
      enum.slice_when { |i, j| yielded << [i, j]; i - 1 != j }.to_a
      expect(yielded).to eq([[10, 9], [9, 7], [7, 6], [6, 4], [4, 3], [3, 2], [2, 1]])
    end

    it 'splits chunks between adjacent elements i and j where the block returns true' do
      enum = EnumerableSpecs::Numerous.new(10, 9, 7, 6, 4, 3, 2, 1)
      result = enum.slice_when { |i, j| i - 1 != j }
      expect(result.to_a).to eq([[10, 9], [7, 6], [4, 3, 2, 1]])
    end

    it 'calls the block for length of the receiver enumerable minus one times' do
      ary = [10, 9, 7, 6, 4, 3, 2, 1]
      enum = EnumerableSpecs::Numerous.new(*ary)
      enum_length = ary.length

      times_called = 0
      enum.slice_when do |i, j|
        times_called += 1
        i - 1 != j
      end.to_a
      expect(times_called).to eq(enum_length - 1)
    end
  end

  context 'when not given a block' do
    it 'raises an ArgumentError' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.slice_when }.to raise_error(ArgumentError, 'tried to create Proc object without a block')
    end
  end

  context 'on a single-element enumerable' do
    it 'ignores the block and returns an enumerator that yields [element]' do
      enum = EnumerableSpecs::Numerous.new(1)
      expect(enum.slice_when { raise }.to_a).to eq([[1]]) # rubocop:disable Lint/UnreachableLoop
    end
  end

  context 'on an empty enumerable' do
    it 'returns an empty enumerator' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.slice_when { raise }.to_a).to eq([]) # rubocop:disable Lint/UnreachableLoop
    end
  end

  context 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.slice_when { false }.to_a).to eq([[[1, 2], [3, 4, 5], [6, 7, 8, 9]]])
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.slice_when { |i, j| yielded << [i, j]; false }.to_a
      expect(yielded).to eq([[[1, 2], [3, 4, 5]], [[3, 4, 5], [6, 7, 8, 9]]])
    end
  end
end
