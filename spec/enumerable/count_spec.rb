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

RSpec.describe 'Enumerable#count' do
  it 'returns the count of elements' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.count).to eq(4)
  end

  it 'ignores the #size method' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    def enum.size = :foo
    expect(enum.count).to eq(4)
  end

  context 'given an argument' do
    it 'returns the number of elements that equal an argument' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 4)
      expect(enum.count(4)).to eq(2)
    end

    it 'compares an argument with elements using #==' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 4)
      object = EnumerableSpecs::Equals.new(4)
      expect(enum.count(object)).to eq(2)
    end

    it 'ignores the block' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 4)

      expect {
        expect(enum.count(4) { raise }).to eq(2) # rubocop:disable Lint/UnreachableLoop
      }.to complain(/given block not used/)
    end
  end

  context 'given a block' do
    it 'uses a block for comparison' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5, 6)
      expect(enum.count { |i| i.even? }).to eq(3)
    end

    it 'yields multiple arguments when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.count { |*args| yielded << args }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end
end
