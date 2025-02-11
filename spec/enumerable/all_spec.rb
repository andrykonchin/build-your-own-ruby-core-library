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

RSpec.describe 'Enumerable#all?' do
  it 'returns whether every element is truthy' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.all?).to be true

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, false)
    expect(enum.all?).to be false

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, nil)
    expect(enum.all?).to be false
  end

  it 'always returns true on empty enumeration' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.all?).to be true
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMultiWithFalse.new
    expect(multi.all?).to be true
  end

  describe 'given a block' do
    it 'returns whether the block returns a truthy value for every element' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.all? { |i| i > 0 }).to be true
      expect(enum.all? { |i| i.even? }).to be false
    end

    it 'yields multiple arguments when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.all? { |*args| yielded << args; true }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end

  describe 'given a pattern argument' do
    it 'returns whether for each element element, pattern === element' do
      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.all?(/a/)).to be true

      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.all?(/d/)).to be false
    end

    it 'calls `#===` on the pattern' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      pattern = EnumerableSpecs::Pattern.new { true }
      enum.all?(pattern)
      expect(pattern.yielded).to contain_exactly([1], [2], [3], [4])
    end

    it 'always returns true on empty enumeration' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.all?(Integer)).to be true
    end

    it 'handles nil value as a pattern as well' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3)
      expect(enum.all?(nil)).to be false

      enum = EnumerableSpecs::Numerous.new(1, 2, false)
      expect(enum.all?(nil)).to be false
    end

    it 'calls the pattern with gathered array when yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { true }
      multi.all?(pattern)
      expect(pattern.yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'ignores the block if there is an argument' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

      expect {
        expect(enum.all?(Integer) { false }).to be true
      }.to complain(/given block not used/)
    end
  end
end
