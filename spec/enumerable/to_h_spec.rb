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

RSpec.describe 'Enumerable#to_h' do
  it 'converts empty enumerable to empty Hash' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.to_h).to eq({})
  end

  it 'converts elements that are [key, value] pairs into a Hash' do
    enum = EnumerableSpecs::Numerous.new([:a, 1], [:b, 2])
    expect(enum.to_h).to eq({ a: 1, b: 2 })
  end

  it 'uses the last value of a duplicated key' do
    enum = EnumerableSpecs::Numerous.new([:a, 1], [:b, 2], [:a, 3])
    expect(enum.to_h).to eq({ a: 3, b: 2 })
  end

  it 'calls #to_ary on elements' do
    pair = double('array')
    allow(pair).to receive(:to_ary).and_return([:b, 2])
    enum = EnumerableSpecs::Numerous.new([:a, 1], pair)
    expect(enum.to_h).to eq({ a: 1, b: 2 })
  end

  it 'passes extra arguments to #each' do
    enum = EnumerableSpecs::EachWithParameters.new([1, 2], [3, 4])
    enum.to_h(:hello, 'world')
    expect(enum.arguments_passed).to eq([:hello, 'world'])
  end

  it 'raises TypeError if an element is not an Array' do
    enum = EnumerableSpecs::Numerous.new(:x)
    expect { enum.to_h }.to raise_error(TypeError, 'wrong element type Symbol (expected array)')
  end

  it 'raises ArgumentError if an element size is less than 2' do
    enum = EnumerableSpecs::Numerous.new([:x])
    expect { enum.to_h }.to raise_error(ArgumentError, 'element has wrong array length (expected 2, was 1)')
  end

  it 'raises ArgumentError if an element size is greater than 2' do
    enum = EnumerableSpecs::Numerous.new(%i[a b c])
    expect { enum.to_h }.to raise_error(ArgumentError, 'element has wrong array length (expected 2, was 3)')
  end

  context 'given a block' do
    it 'converts [key, value] pairs returned by the block into a Hash' do
      enum = EnumerableSpecs::Numerous.new(:a, :b)
      expect(enum.to_h { |k| [k, k.to_s] }).to eq({ a: 'a', b: 'b' })
    end

    it 'yields multiple arguments when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.to_h { |*args| yielded << args; [:a, 1] }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end

    it 'raises ArgumentError if block returns longer or shorter Array' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.to_h { |k| [k, k, k] }
      }.to raise_error(ArgumentError, 'element has wrong array length (expected 2, was 3)')

      expect {
        enum.to_h { |k| [k] }
      }.to raise_error(ArgumentError, 'element has wrong array length (expected 2, was 1)')
    end

    it 'raises TypeError if block returns something other than Array' do
      enum = EnumerableSpecs::Numerous.new

      expect {
        enum.to_h { 'not-array' }
      }.to raise_error(TypeError, 'wrong element type String (expected array)')
    end

    it 'coerces returned pair to Array with #to_ary' do
      enum = EnumerableSpecs::Numerous.new

      x = double('x', to_ary: [:b, 'b'])
      expect(enum.to_h { x }).to eq({ b: 'b' })
    end

    it 'does not coerce returned pair to Array with #to_a' do
      enum = EnumerableSpecs::Numerous.new
      x = double('x', to_a: [:b, 'b'])

      expect {
        enum.to_h { x }
      }.to raise_error(TypeError, 'wrong element type RSpec::Mocks::Double (expected array)')
    end
  end
end
