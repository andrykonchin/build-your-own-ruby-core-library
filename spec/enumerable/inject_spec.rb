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

RSpec.describe 'Enumerable#inject' do
  it 'reduces a collection to a single value given an initial value and a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.inject(5) { |acc, e| acc + e }).to eq(5 + 1 + 2 + 3 + 4)
  end

  it 'uses the first element as an initial value when initial value is not given' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.inject { |acc, e| acc + e }).to eq(1 + 2 + 3 + 4)
  end

  it 'accepts a name of a method instead of a block when given initial value and a Symbol' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.inject(5, :+)).to eq(5 + 1 + 2 + 3 + 4)
  end

  it 'uses the first element as an initial value when only a name of a method given' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.inject(:+)).to eq(1 + 2 + 3 + 4)
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.inject([]) { |acc, e| yielded << e; acc + e }
    expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
  end

  context 'empty Enumerable' do
    it 'returns initial value given an initial value and a block' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.inject(1) { |acc, e| acc + e }).to eq(1)
    end

    it 'returns nil given a block' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.inject { |acc, e| acc + e }).to be_nil
    end

    it 'returns initial value given an initial value and a method name' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.inject(1, :+)).to eq(1)
    end

    it 'returns nil given a method name' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.inject(:+)).to be_nil
    end
  end

  context 'a method name argument type conversion' do
    it 'converts non-Symbol method name argument to String first with #to_str' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      name = double(to_str: '+')
      expect(enum.inject(5, name)).to eq(5 + 1 + 2 + 3 + 4)
      expect(enum.inject(name)).to eq(1 + 2 + 3 + 4)
    end

    it 'raises TypeError when a non-Symbol/String method name argument does not respond to #to_str method' do
      enum = EnumerableSpecs::Numerous.new
      name = Object.new
      expect { enum.inject(name) }.to raise_error(TypeError, "#{name} is not a symbol nor a string")
    end

    it 'raises TypeError when #to_str method returns non-String value' do
      enum = EnumerableSpecs::Numerous.new
      name = double('name', to_str: [])

      expect {
        enum.inject(name)
      }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to String (RSpec::Mocks::Double#to_str gives Array)")
    end
  end

  context 'given two arguments and a block' do
    it 'ignores block and emits a warning' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

      expect {
        expect(enum.inject(5, :+) { raise 'we never get here' }).to eq(5 + 1 + 2 + 3 + 4) # rubocop:disable Lint/UnreachableLoop
      }.to complain(/warning: given block not used/, verbose: true)
    end
  end

  context 'given no arguments and a no block' do
    it 'raises ArgumentError' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.inject
      }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1..2)')
    end
  end

  context 'given extra arguments' do
    it 'raises ArgumentError' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.inject(1, :+, 'extra')
      }.to raise_error(ArgumentError, 'wrong number of arguments (given 3, expected 1..2)')
    end
  end
end
