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

RSpec.describe 'Enumerable#grep' do
  it 'returns an array of objects based on elements of self that match the given pattern' do
    enum = EnumerableSpecs::Numerous.new('a', 'b', 'ab', 'bc')
    expect(enum.grep(/a/)).to contain_exactly('a', 'ab')
  end

  it 'returns an array containing each element for which `pattern === element` is true' do
    enum = EnumerableSpecs::Numerous.new(1, -2, 3, -4)

    pattern = Object.new
    def pattern.===(v)
      v > 0
    end

    expect(enum.grep(pattern)).to contain_exactly(1, 3)
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    pattern = EnumerableSpecs::Pattern.new { true }
    expect(multi.grep(pattern)).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    expect(pattern.yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
  end

  context 'given a block' do
    it 'calls the block with each matching element and returns an array containing each object returned by the block' do
      enum = EnumerableSpecs::Numerous.new('a', 'b', 'ab', 'bc')
      expect(enum.grep(/a/) { |s| s.to_sym }).to contain_exactly(:a, :ab)
    end

    it 'yields multiple values as array when #each yields multiple' do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { true }
      yielded = []
      multi.grep(pattern) { |*args| yielded << args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'can use $~ in the block when used with a Regexp' do
      skip "it's unclear how to implement in pure Ruby"

      ary = EnumerableSpecs::Numerous.new('aba', 'aba')
      expect(ary.grep(/a(b)a/) { $1 }).to eq(%w[b b])
    end

    it 'sets $~ in the block' do
      skip "it's unclear how to implement in pure Ruby"

      'z' =~ /z/ # Reset $~
      EnumerableSpecs::Numerous.new('abc', 'def').grep(/b/) { |e|
        expect(e).to eq('abc')
        expect($&).to eq('b')
      }

      # Set by the failed match of "def"
      expect($~).to be_nil
    end
  end
end
