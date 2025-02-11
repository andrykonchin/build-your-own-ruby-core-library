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

RSpec.describe 'Enumerable#take_while' do
  it 'calls the block with successive elements as long as the block returns a truthy value; returns an array of all elements up to that point' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.take_while { |i| i < 3 }).to eq([1, 2])
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.take_while).to be_an_instance_of(Enumerator)
    expect(enum.take_while.to_a).to eq([1])
    expect(enum.take_while.each { |i| i < 3 }).to eq([1, 2])
  end

  it 'passes elements to the block until the first false' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    a = []
    enum.take_while { |i| a << i; i < 3 }
    expect(a).to eq([1, 2, 3])
  end

  describe 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.take_while { true }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it 'yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.take_while { |*args| yielded << args; true }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.take_while.size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.take_while.size).to be_nil
        end
      end
    end
  end
end
