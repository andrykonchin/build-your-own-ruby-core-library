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

RSpec.describe 'Enumerable#sum' do
  it 'returns the sum of initial value and the elements' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.sum(1)).to eq(1 + 1 + 2 + 3 + 4)

    enum = EnumerableSpecs::Numerous.new('b', 'c', 'd', 'e')
    expect(enum.sum('a')).to eq('abcde')
  end

  it 'uses 0 as an initial argument if given no argument' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.sum).to eq(1 + 2 + 3 + 4)
  end

  context 'given a block' do
    it 'returns the sum of initial value and the block return values' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.sum(1) { |e| e * 10 }).to eq(1 + 10 + 20 + 30 + 40)
    end

    it 'yields multiple arguments as array when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.sum { |*args| yielded << args; 0 }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end
end
