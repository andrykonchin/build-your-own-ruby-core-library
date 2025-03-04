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

RSpec.describe 'Range#first' do
  it 'returns self.begin' do
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)
    range = Range.new(a, b)
    expect(range.first).to equal(a)
  end

  it 'returns self.begin even when self is empty' do
    a = RangeSpecs::Element.new(0)
    expect(Range.new(a, a, true).first).to equal(a)
  end

  it 'returns self.begin even when self is backward' do
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)

    expect(Range.new(b, a).first).to equal(b)
  end

  it 'returns self.begin when a range is not iterable' do
    a = RangeSpecs::WithoutSucc.new(0)
    b = RangeSpecs::WithoutSucc.new(1)
    range = Range.new(a, b)

    expect(range.first).to eq(a)
  end

  it 'raises RangeError when there is no first element' do
    range = Range.new(nil, RangeSpecs::Element.new(0))

    expect {
      range.first
    }.to raise_error(RangeError, 'cannot get the first element of beginless range')
  end

  describe 'given an argument' do
    it 'returns the first n elements in an array' do
      range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))

      expect(range.first(2)).to eq(
        [
          RangeSpecs::WithSucc.new(1),
          RangeSpecs::WithSucc.new(2)
        ]
      )
    end

    it "doesn't yield self.end when end is excluded" do
      range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
      expect(range.first(4)).to eq(
        [
          RangeSpecs::WithSucc.new(1),
          RangeSpecs::WithSucc.new(2),
          RangeSpecs::WithSucc.new(3)
        ]
      )
    end

    it 'returns an empty array when a range is empty' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0), true)
      expect(range.first(2)).to eq([])
    end

    it 'returns an empty array when a range is backward' do
      range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(0))
      expect(range.first(2)).to eq([])
    end

    it 'returns an empty array when n is zero' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
      expect(range.first(0)).to eq([])
    end

    it 'raises RangeError when there is no first element' do
      range = Range.new(nil, RangeSpecs::WithSucc.new(1))

      expect {
        range.first(2)
      }.to raise_error(RangeError, 'cannot get the first element of beginless range')
    end

    it 'raises an ArgumentError when an argument is negative' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

      # The error message "negative array size (or size too big)" is
      # Array-specific and doesn't match similar error messages in Enumerable.
      # CRuby creates a temporary Array so it fails first
      expect {
        range.first(-1)
      }.to raise_error(ArgumentError, /negative array size \(or size too big\)|attempt to take negative size/)
    end

    it 'raises a RangeError when passed a Bignum' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

      expect {
        range.first(bignum_value)
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    it 'returns all elements in the range when n exceeds the number of elements' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
      expect(range.first(100)).to eq(
        [
          RangeSpecs::WithSucc.new(0),
          RangeSpecs::WithSucc.new(1)
        ]
      )
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
        n = double('n', to_int: 2)

        expect(range.first(n)).to eq(
          [
            RangeSpecs::WithSucc.new(0),
            RangeSpecs::WithSucc.new(1)
          ]
        )
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

        expect { range.first(nil) }.to raise_error(TypeError, 'no implicit conversion from nil to integer')
        expect { range.first('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
        n = double('n', to_int: 'a')

        expect {
          range.first(n)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end
end
