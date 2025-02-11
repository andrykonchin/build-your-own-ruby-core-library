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

RSpec.describe 'Enumerable#tally' do
  it 'returns a new hash whose keys are the distinct elements in self; each integer value is the count of occurrences of each element' do
    enum = EnumerableSpecs::Numerous.new(:a, :b, :a)
    expect(enum.tally).to eq({ a: 2, b: 1 })
  end

  it 'returns a Hash without default' do
    enum = EnumerableSpecs::Numerous.new
    hash = enum.tally
    expect(hash.default_proc).to be_nil
    expect(hash.default).to be_nil
  end

  it 'returns an empty Hash for empty enumerables' do
    expect(EnumerableSpecs::Empty.new.tally).to eq({})
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.tally).to eq([1, 2] => 1, [3, 4, 5] => 1, [6, 7, 8, 9] => 1)
  end

  describe 'with a Hash argument' do
    it 'returns the given Hash' do
      enum = EnumerableSpecs::Numerous.new(:a, :b, :a)
      hash = { a: 1 }
      expect(enum.tally(hash)).to equal(hash)
    end

    it 'updates the given Hash with new keys' do
      enum = EnumerableSpecs::Numerous.new(:a, :b, :a)
      expect(enum.tally(c: 1)).to eq(a: 2, b: 1, c: 1)
    end

    it 'updates the given Hash and increments already present keys counts' do
      enum = EnumerableSpecs::Numerous.new(:a, :b)
      expect(enum.tally(a: 1)).to eq(a: 2, b: 1)
    end

    describe 'argument conversion to Hash' do
      it 'converts the passed argument to Hash using #to_hash' do
        enum = EnumerableSpecs::Numerous.new(:a, :b, :a)
        hash = double('hash', to_hash: { c: 1 })
        expect(enum.tally(hash)).to eq(a: 2, b: 1, c: 1)
      end

      it 'raises a TypeError if the passed argument does not respond to #to_hash' do
        enum = EnumerableSpecs::Numerous.new
        expect { enum.tally('hat') }.to raise_error(TypeError, 'no implicit conversion of String into Hash')
        expect { enum.tally(nil) }.to raise_error(TypeError, 'no implicit conversion of nil into Hash')
      end

      it 'raises a TypeError if the passed argument responds to #to_hash but it returns non-Hash value' do
        enum = EnumerableSpecs::Numerous.new
        hash = double('hash', to_hash: 'a')
        expect { enum.tally(hash) }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Hash (RSpec::Mocks::Double#to_hash gives String)")
      end
    end

    it 'raises a FrozenError when the Hash is frozen' do
      enum = EnumerableSpecs::Numerous.new(:a)
      hash = { b: 1 }.freeze

      expect {
        enum.tally(hash)
      }.to raise_error(FrozenError, "can't modify frozen Hash: {b: 1}")
    end

    it 'raises a FrozenError when the Hash is frozen even if enumerable is empty' do
      enum = EnumerableSpecs::Empty.new
      hash = { b: 1 }.freeze

      expect {
        enum.tally(hash)
      }.to raise_error(FrozenError, "can't modify frozen Hash: {b: 1}")
    end

    it 'ignores the default value' do
      enum = EnumerableSpecs::Numerous.new(:a, :b, :a)
      hash = Hash.new(100)
      expect(enum.tally(hash)).to eq(a: 2, b: 1)
    end

    it 'ignores the default proc' do
      enum = EnumerableSpecs::Numerous.new(:a, :b, :a)
      hash = Hash.new { 100 }
      expect(enum.tally(hash)).to eq(a: 2, b: 1)
    end

    it 'raises TypeError if the Hash values are not Integer' do
      enum = EnumerableSpecs::Numerous.new(:a)
      hash = { a: 'a' }

      expect {
        enum.tally(hash)
      }.to raise_error(TypeError, 'wrong argument type String (expected Integer)')
    end
  end
end
