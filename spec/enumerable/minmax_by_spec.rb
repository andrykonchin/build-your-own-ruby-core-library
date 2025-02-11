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

RSpec.describe 'Enumerable#minmax_by' do
  it 'returns a 2-element array containing the elements for which the block returns minimum and maximum values' do
    enum = EnumerableSpecs::Numerous.new(*%w[3 111 22])
    expect(enum.minmax_by { |e| e.size }).to eq(%w[3 111])
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.minmax_by).to be_an_instance_of(Enumerator)
    expect(enum.minmax_by.to_a).to eq([1, 2, 3, 4])
    expect(enum.minmax_by.each { |e| e }).to eq([1, 4]) # rubocop:disable Lint/Void
  end

  it 'compares elements with #<=> method' do
    a, b, c = (1..3).map { |n| EnumerableSpecs::ReverseComparable.new(n) }
    enum = EnumerableSpecs::Numerous.new(a, b, c)
    expect(enum.minmax_by { |obj| obj }).to eq([c, a])
  end

  it 'returns [nil, nil] for an empty Enumerable' do
    expect(EnumerableSpecs::Empty.new.minmax_by { |o| o }).to eq([nil, nil])
  end

  it 'returns [element, element] for an Enumerable with only one element' do
    enum = EnumerableSpecs::Numerous.new(1)
    expect(enum.minmax_by { |o| o }).to eq([1, 1])
  end

  it 'raises a NoMethodError for elements not responding to #<=>' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

    expect {
      enum.minmax_by { BasicObject.new }
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it 'raises an ArgumentError when elements are incompatible' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

    expect {
      enum.minmax_by { EnumerableSpecs::Uncomparable.new }
    }.to raise_error(ArgumentError, 'comparison of EnumerableSpecs::Uncomparable with EnumerableSpecs::Uncomparable failed')
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.minmax_by { |e| e.size }).to eq([[1, 2], [6, 7, 8, 9]])
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.minmax_by { |*args| yielded << args; args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.minmax_by.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.minmax_by.size).to be_nil
        end
      end
    end
  end
end
