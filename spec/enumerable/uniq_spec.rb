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

RSpec.describe 'Enumerable#uniq' do
  it 'returns a new array containing only unique elements' do
    expect(EnumerableSpecs::Numerous.new(0, 1, 0, 3).uniq).to eq([0, 1, 3])
  end

  it 'returns a new array containing elements only for which a block returns a unique value when the block is given' do
    expect(EnumerableSpecs::Numerous.new(0, 1, 2, 3).uniq { |n| n % 2 }).to eq([0, 1])
  end

  it 'uses #eql? semantics' do
    expect(EnumerableSpecs::Numerous.new(1.0, 1).to_enum.uniq).to eq([1.0, 1])
  end

  it 'compares elements first with #hash' do
    x = double('0')
    expect(x).to receive(:hash).at_least(1).and_return(0)
    y = double('0')
    expect(y).to receive(:hash).at_least(1).and_return(0)

    expect(EnumerableSpecs::Numerous.new(x, y).to_enum.uniq).to eq([x, y])
  end

  it 'does not compare elements with different hash codes via #eql?' do
    x = double('0')
    expect(x).not_to receive(:eql?)
    y = double('1')
    expect(y).not_to receive(:eql?)

    expect(x).to receive(:hash).at_least(1).and_return(0)
    expect(y).to receive(:hash).at_least(1).and_return(1)

    expect(EnumerableSpecs::Numerous.new(x, y).to_enum.uniq).to eq([x, y])
  end

  it 'compares elements with matching hash codes with #eql?' do
    a = double('a', eql?: false)
    b = double('b', eql?: false)
    enum = EnumerableSpecs::Numerous.new(a, b)

    expect(a).to receive(:hash).at_least(1).and_return(0)
    expect(b).to receive(:hash).at_least(1).and_return(0)
    expect(enum.uniq).to eq([a, b])

    a = double('a', eql?: true)
    b = double('b', eql?: true)
    enum = EnumerableSpecs::Numerous.new(a, b)

    expect(a).to receive(:hash).at_least(1).and_return(0)
    expect(b).to receive(:hash).at_least(1).and_return(0)
    expect(enum.uniq.size).to eq(1)
  end

  describe 'when #each yields multiple values' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      i = 0
      expect(multi.uniq { i += 1 }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it 'yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.uniq { |*args| yielded << args; false }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end
end
