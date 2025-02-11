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

RSpec.describe 'Enumerable#minmax' do
  it 'returns a 2-element array containing the minimum and the maximum elements' do
    enum = EnumerableSpecs::Numerous.new(6, 4, 5, 10, 8)
    expect(enum.minmax).to eq([4, 10])
  end

  it 'compares elements with #<=> method' do
    a = double('a', value: 'a')
    def a.<=>(o); value <=> o.value; end

    b = double('b', value: 'b')
    def b.<=>(o); value <=> o.value; end

    c = double('c', value: 'c')
    def c.<=>(o); value <=> o.value; end

    expect(EnumerableSpecs::Numerous.new(a, c, b).minmax).to eq([a, c])
  end

  it 'compares elements using a block when it is given' do
    enum = EnumerableSpecs::Numerous.new(6, 4, 5, 10, 8)
    expect(enum.minmax { |a, b| b <=> a }).to eq([10, 4])
  end

  it 'returns [nil, nil] for an empty Enumerable' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.minmax).to eq([nil, nil])
  end

  it 'returns [element, element] for an Enumerable with only one element' do
    enum = EnumerableSpecs::Numerous.new(1)
    expect(enum.minmax).to eq([1, 1])
  end

  it 'raises a NoMethodError for elements not responding to #<=>' do
    enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new)

    expect {
      enum.minmax
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it 'raises an ArgumentError when elements are incompatible' do
    enum = EnumerableSpecs::Numerous.new(11, '22')

    expect {
      enum.minmax
    }.to raise_error(ArgumentError, 'comparison of Integer with String failed')
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.minmax).to eq([[1, 2], [6, 7, 8, 9]])
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = Set.new
      multi.minmax { |*args| yielded += args; 0 }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end
end
