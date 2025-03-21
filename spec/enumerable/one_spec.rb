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

RSpec.describe 'Enumerable#one?' do
  it 'returns whether exactly one element is truthy' do
    enum = EnumerableSpecs::Numerous.new(1, false, false)
    expect(enum.one?).to be true

    enum = EnumerableSpecs::Numerous.new(1, nil, nil)
    expect(enum.one?).to be true

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.one?).to be false

    enum = EnumerableSpecs::Numerous.new(false, false)
    expect(enum.one?).to be false

    enum = EnumerableSpecs::Numerous.new(nil, nil)
    expect(enum.one?).to be false
  end

  it 'always returns false on empty enumeration' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.one?).to be false
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMultiWithSingleTrue.new
    expect(multi.one?).to be false
  end

  describe 'given a block' do
    it 'returns whether the block returns a truthy value for exactly one element' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.one? { |i| i == 1 }).to be true
      expect(enum.one? { |i| i > 2 }).to be false
    end

    it 'yields multiple arguments when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.one? { |*args| yielded << args; false }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end

  describe 'given a pattern argument' do
    it 'returns whether for exactly one element, pattern === element' do
      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.one?(/d/)).to be true

      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.one?(/b/)).to be false
    end

    it 'calls `#===` on the pattern' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      pattern = EnumerableSpecs::Pattern.new { false }
      enum.one?(pattern)
      expect(pattern.yielded).to contain_exactly([1], [2], [3], [4])
    end

    it 'always returns false on empty enumeration' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.one?(Integer)).to be false
    end

    it 'handles nil value as a pattern as well' do
      enum = EnumerableSpecs::Numerous.new(1, false, false)
      expect(enum.one?(nil)).to be false

      enum = EnumerableSpecs::Numerous.new(false, false, false)
      expect(enum.one?(nil)).to be false
    end

    it 'calls the pattern with gathered array when yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      multi.one?(pattern)
      expect(pattern.yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'ignores the block if there is an argument' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, '5')

      expect {
        expect(enum.one?(String) { false }).to be true
      }.to complain(/given block not used/)
    end
  end
end
