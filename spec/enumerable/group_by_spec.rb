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

RSpec.describe 'Enumerable#group_by' do
  it 'returns a Hash such as each key is a returned value from the block and each value is an array of those elements for which the block returned that key' do
    enum = EnumerableSpecs::Numerous.new('a', 'b', 'abc')
    expect(enum.group_by { |s| s.size }).to eq({ 1 => %w[a b], 3 => ['abc'] })
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new('a', 'b', 'abc')
    expect(enum.group_by).to be_an_instance_of(Enumerator)
    expect(enum.group_by.to_a).to contain_exactly('a', 'b', 'abc')
    expect(enum.group_by.each { |s| s.size }).to eq({ 1 => %w[a b], 3 => ['abc'] })
  end

  it 'returns an empty Hash for empty Enumerables' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.group_by { |x| x }).to eq({})
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements when #each yields multiple' do
      enum = EnumerableSpecs::YieldsMulti.new
      expect(enum.group_by { |i| i }).to eq(
        {
          [1, 2] => [[1, 2]],
          [6, 7, 8, 9] => [[6, 7, 8, 9]],
          [3, 4, 5] => [[3, 4, 5]]
        }
      )
    end

    it 'yields multiple values as array' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.group_by { |*args| yielded << args; args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.group_by.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.group_by.size).to be_nil
        end
      end
    end
  end
end
