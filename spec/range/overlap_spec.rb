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

RSpec.describe 'Range#overlap?' do
  context 'given non-Range argument' do
    it 'raises TypeError' do
      a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))

      expect {
        a.overlap?(Object.new)
      }.to raise_error(TypeError, 'wrong argument type Object (expected Range)')
    end
  end

  context 'given Range argument' do
    context 'other range is completely inside the self' do
      it 'returns true if self.begin < other.begin and self.end > other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end > other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin < other.begin and self.end == other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end == other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10), true)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(nil, RangeSpecs::Element.new(10), true)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is endless and self.begin < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is endless and self.begin == other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil, true)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(0), nil, true)
        expect(a.overlap?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is finit' do
        a = Range.new(nil, nil)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is beginingless' do
        a = Range.new(nil, nil)
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is endless' do
        a = Range.new(nil, nil)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is finit' do
        a = Range.new(nil, nil, true)
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is beginingless' do
        a = Range.new(nil, nil, true)
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is endless and other.excluded_end? is true' do
        a = Range.new(nil, nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil, true)
        expect(a.overlap?(b)).to be true
      end
    end

    context 'partially interleave' do
      it 'returns true if self.begin > other.begin, self.begin < other.end and self.end > other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin > other.begin, self.begin < other.end and self.end == other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin > other.begin, self.begin < other.end and self.end < other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin < other.begin and self.end > other.begin, self.end < other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin < other.begin and self.end == other.end and self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self.begin < other.begin and self.end == other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end > other.begin but self.end < other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(6), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are beginingless but self.end < other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(6))
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end == other.end but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is endless and self.begin > other.begin' do
        a = Range.new(RangeSpecs::Element.new(4), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin > other.begin' do
        a = Range.new(RangeSpecs::Element.new(4), nil)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin but self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin but self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'return false if self is (nil...nil) and other is endless' do
        a = Range.new(nil, nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is beginingless and other is endless and self.end == other.begin' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if other is beginingless and self is endless and other.end == self.begin' do
        a = Range.new(RangeSpecs::Element.new(10), nil)
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end
    end

    context 'not interleave' do
      it 'returns false if self.begin > other.end' do
        a = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self.end < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is beginingless but self.end < other.begin' do
        a = Range.new(nil, RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end == other.begin but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(4), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless but self.end < other.begin' do
        a = Range.new(nil, RangeSpecs::Element.new(0))
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless and self.end == other.begin but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is endless but self.begin > other.end' do
        a = Range.new(RangeSpecs::Element.new(10), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is endless but self.begin == other.end but other.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(6), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6), true)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if other is beginingless but self.begin > other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(0))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if other is beginingless and self.begin == other.end but other.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(6), true)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if other is beginingless and self is endless and other.end == self.begin but other.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(10), nil)
        b = Range.new(nil, RangeSpecs::Element.new(10), true)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if other is endless but self.end < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if other is endless and self.end == other.begin but self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.overlap?(b)).to be false
      end
    end

    context 'backward ranges' do
      it 'returns false if other is backward and fits into the self' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(4))
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is backward and other fits into the self' do
        a = Range.new(RangeSpecs::Element.new(10), RangeSpecs::Element.new(0))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be false
      end
    end

    context 'empty ranges' do
      it 'returns false if other is empty and fits into the self' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(4), true)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self is empty and equals other' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
        expect(a.overlap?(b)).to be false
      end

      it 'returns false if self and other are empty and equal' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(4), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(4), true)
        expect(a.overlap?(b)).to be false
      end
    end
  end
end

# rubocop: disable
# TODO: remove when implemented
RSpec.describe 'Range#overlap?' do
  it 'returns true if other Range overlaps self' do
    expect(Range.new(0, 2).overlap?(Range.new(1, 3))).to be(true)
    expect(Range.new(1, 3).overlap?(Range.new(0, 2))).to be(true)
    expect(Range.new(0, 2).overlap?(Range.new(0, 2))).to be(true)
    expect(Range.new(0, 3).overlap?(Range.new(1, 2))).to be(true)
    expect(Range.new(1, 2).overlap?(Range.new(0, 3))).to be(true)

    expect(Range.new('a', 'c').overlap?(Range.new('b', 'd'))).to be(true)
  end

  it 'returns false if other Range does not overlap self' do
    expect(Range.new(0, 2).overlap?(Range.new(3, 4))).to be(false)
    expect(Range.new(0, 2).overlap?(Range.new(-4, -1))).to be(false)

    expect(Range.new('a', 'c').overlap?(Range.new('d', 'f'))).to be(false)
  end

  it 'raises TypeError when called with non-Range argument' do
    expect {
      Range.new(0, 2).overlap?(1)
    }.to raise_error(TypeError, 'wrong argument type Integer (expected Range)')
  end

  it 'returns true when beginningless and endless Ranges overlap' do
    expect(Range.new(0, 2).overlap?(Range.new(nil, 3))).to be(true)
    expect(Range.new(0, 2).overlap?(Range.new(nil, 1))).to be(true)
    expect(Range.new(0, 2).overlap?(Range.new(nil, 0))).to be(true)

    expect(Range.new(nil, 3).overlap?(Range.new(0, 2))).to be(true)
    expect(Range.new(nil, 1).overlap?(Range.new(0, 2))).to be(true)
    expect(Range.new(nil, 0).overlap?(Range.new(0, 2))).to be(true)

    expect(Range.new(0, 2).overlap?(Range.new(-1, nil))).to be(true)
    expect(Range.new(0, 2).overlap?(Range.new(1, nil))).to be(true)
    expect(Range.new(0, 2).overlap?(Range.new(2, nil))).to be(true)

    expect(Range.new(-1, nil).overlap?(Range.new(0, 2))).to be(true)
    expect(Range.new(1, nil).overlap?(Range.new(0, 2))).to be(true)
    expect(Range.new(2, nil).overlap?(Range.new(0, 2))).to be(true)

    expect(Range.new(0, nil).overlap?(Range.new(2, nil))).to be(true)
    expect(Range.new(nil, 0).overlap?(Range.new(nil, 2))).to be(true)
  end

  it 'returns false when beginningless and endless Ranges do not overlap' do
    expect(Range.new(0, 2).overlap?(..-1)).to be(false)
    expect(Range.new(0, 2).overlap?(3..)).to be(false)

    expect(Range.new(nil, -1).overlap?(Range.new(0, 2))).to be(false)
    expect(Range.new(3, nil).overlap?(Range.new(0, 2))).to be(false)
  end

  it 'returns false when Ranges are not compatible' do
    expect(Range.new(0, 2).overlap?(Range.new('a', 'd'))).to be(false)
  end

  it 'return false when self is empty' do
    expect(Range.new(2, 0).overlap?(Range.new(1, 3))).to be(false)
    expect(Range.new(2, 2, true).overlap?(Range.new(1, 3))).to be(false)
    expect(Range.new(1, 1, true).overlap?(Range.new(1, 1, true))).to be(false)
    expect(Range.new(2, 0).overlap?(Range.new(2, 0))).to be(false)

    expect(Range.new('c', 'a').overlap?(Range.new('b', 'd'))).to be(false)
    expect(Range.new('a', 'a', true).overlap?(Range.new('b', 'd'))).to be(false)
    expect(Range.new('b', 'b', true).overlap?(Range.new('b', 'b', true))).to be(false)
    expect(Range.new('c', 'a', true).overlap?(Range.new('c', 'a', true))).to be(false)
  end

  it 'return false when other Range is empty' do
    expect(Range.new(1, 3).overlap?(Range.new(2, 0))).to be(false)
    expect(Range.new(1, 3).overlap?(Range.new(2, 2, true))).to be(false)

    expect(Range.new('b', 'd').overlap?(Range.new('c', 'a'))).to be(false)
    expect(Range.new('b', 'd').overlap?(Range.new('c', 'c', true))).to be(false)
  end

  it 'takes into account exclusive end' do
    expect(Range.new(0, 2, true).overlap?(Range.new(2, 4))).to be(false)
    expect(Range.new(2, 4).overlap?(Range.new(0, 2, true))).to be(false)

    expect(Range.new('a', 'c', true).overlap?(Range.new('c', 'e'))).to be(false)
    expect(Range.new('c', 'e').overlap?(Range.new('a', 'c', true))).to be(false)
  end
end
# rubocop: enable
