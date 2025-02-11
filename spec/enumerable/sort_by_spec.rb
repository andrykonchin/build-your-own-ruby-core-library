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

RSpec.describe 'Enumerable#sort_by' do
  it 'returns an array of elements ordered by the result of block' do
    enum = EnumerableSpecs::Numerous.new('once', 'upon', 'a', 'time')
    expect(enum.sort_by { |i| i[0] }).to eq(%w[a once time upon])
  end

  it 'returns an Enumerator when a block is not supplied' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.sort_by).to be_an_instance_of(Enumerator)
    expect(enum.sort_by.to_a).to eq([1, 2, 3, 4])
    expect(enum.sort_by.each { |i| -i }).to eq([4, 3, 2, 1])
  end

  it 'raises a NoMethodError if elements do not respond to <=>' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

    expect {
      enum.sort_by { BasicObject.new }
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it "raises an error if objects can't be compared, that is <=> returns nil" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

    expect {
      enum.sort_by { EnumerableSpecs::Uncomparable.new }
    }.to raise_error(ArgumentError, 'comparison of EnumerableSpecs::Uncomparable with EnumerableSpecs::Uncomparable failed')
  end

  describe 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.sort_by { |e| e }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]]) # rubocop:disable Style/RedundantSortBy
    end

    it 'yields whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.sort_by { |*args| yielded << args; args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.sort_by.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.sort_by.size).to be_nil
        end
      end
    end
  end
end
