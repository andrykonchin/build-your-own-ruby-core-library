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

RSpec.describe 'Enumerable#slice_after' do
  describe 'when given an argument and no block' do
    it 'calls #=== on the argument to determine when a slice ends' do
      enum = EnumerableSpecs::Numerous.new(1, '2', 3, '4', 5, '6', 7)
      e = enum.slice_after(String)
      expect(e.to_a).to eq([[1, '2'], [3, '4'], [5, '6'], [7]])
    end

    it 'returns an Enumerator' do
      enum = EnumerableSpecs::Numerous.new
      e = enum.slice_after(String)
      expect(e).to be_an_instance_of(Enumerator)
    end

    it 'checks whether #=== returns a truthy value' do
      enum = EnumerableSpecs::Numerous.new(7, 6, 5, 4, 3, 2, 1)
      pattern = double('filter')
      expect(pattern).to receive(:===).and_return(false, :foo, nil, false, false, 42, false)

      e = enum.slice_after(pattern)
      expect(e.to_a).to eq([[7, 6], [5, 4, 3, 2], [1]])
    end
  end

  describe 'when given a block' do
    it 'uses the block' do
      enum = EnumerableSpecs::Numerous.new(7, 6, 5, 4, 3, 2, 1)
      e = enum.slice_after { |i| [6, 2].include?(i) }
      expect(e).to be_an_instance_of(Enumerator)
      expect(e.to_a).to eq([[7, 6], [5, 4, 3, 2], [1]])
    end

    it 'returns an Enumerator' do
      enum = EnumerableSpecs::Numerous.new(7, 6, 5, 4, 3, 2, 1)
      e = enum.slice_after { |i| [6, 2].include?(i) }
      expect(e).to be_an_instance_of(Enumerator)
    end

    it 'raises ArgumentError when given a pattern argument' do
      expect {
        EnumerableSpecs::Numerous.new.slice_after(String) {}
      }.to raise_error(ArgumentError, 'both pattern and block are given')
    end

    it 'raises ArgumentError when given a nil argument as well' do
      expect {
        EnumerableSpecs::Numerous.new.slice_after(nil) {}
      }.to raise_error(ArgumentError, 'both pattern and block are given')
    end

    it 'raises ArgumentError when given extra arguments' do
      expect {
        EnumerableSpecs::Numerous.new.slice_after(String, 'one', 'two') {}
      }.to raise_error(ArgumentError, 'both pattern and block are given')
    end
  end

  it 'raises an ArgumentError when given two or more arguments' do
    expect {
      EnumerableSpecs::Numerous.new.slice_after('one', 'two')
    }.to raise_error(ArgumentError, 'wrong number of arguments (given 2, expected 1)')
  end

  it 'raises an ArgumentError when given no arguments and no block' do
    expect {
      EnumerableSpecs::Numerous.new.slice_after
    }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
  end

  describe 'when #each yields multiple values' do
    context 'given an argument and no block' do
      it 'gathers whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        pattern = double('pattern', '===': true)
        expect(multi.slice_after(pattern).to_a).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
      end
    end

    context 'given a block' do
      it 'gathers whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        expect(multi.slice_after { true }.to_a).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
      end

      it 'yields whole arrays as elements' do
        multi = EnumerableSpecs::YieldsMulti.new
        yielded = []
        multi.slice_after { |*args| yielded << args; true }.to_a
        expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
      end
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.slice_after(3).size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.slice_after(3).size).to be_nil
        end
      end
    end
  end
end
