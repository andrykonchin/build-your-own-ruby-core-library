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

RSpec.describe 'Range#cover?' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  context 'given non-Range argument' do
    it 'returns true if object is between self.begin and self.end' do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(5)
      expect(range.cover?(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(-5)
      expect(range.cover?(object)).to be false
    end

    it 'returns false if object is greater than self.end' do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(10)
      expect(range.cover?(object)).to be false
    end

    it 'ignores end if excluded end' do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6), true)
      object = RangeSpecs::Element.new(6)
      expect(range.cover?(object)).to be false
    end

    it 'returns true if argument is a single element in the range' do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0))
      object = RangeSpecs::Element.new(0)
      expect(range.cover?(object)).to be true
    end

    it 'returns false if range is empty' do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
      object = RangeSpecs::Element.new(0)
      expect(range.cover?(object)).to be false
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      expect(range.cover?(Object.new)).to be false
    end

    context 'beginingless range' do
      it 'returns false if object is greater than self.end' do
        range = described_class.new(nil, RangeSpecs::Element.new(6))
        object = RangeSpecs::Element.new(10)
        expect(range.cover?(object)).to be false
      end

      it 'returns true if object is smaller than self.end' do
        range = described_class.new(nil, RangeSpecs::Element.new(6))
        object = RangeSpecs::Element.new(0)
        expect(range.cover?(object)).to be true
      end
    end

    context 'endless range' do
      it 'returns true if object is greater than self.begin' do
        range = described_class.new(RangeSpecs::Element.new(0), nil)
        object = RangeSpecs::Element.new(10)
        expect(range.cover?(object)).to be true
      end

      it 'returns false if object is smaller than self.begin' do
        range = described_class.new(RangeSpecs::Element.new(0), nil)
        object = RangeSpecs::Element.new(-10)
        expect(range.cover?(object)).to be false
      end
    end

    it 'returns true on any value for (nil..nil)' do
      expect(described_class.new(nil, nil).cover?(Object.new)).to be true
    end

    it "returns false if object isn't comparable with self.begin and self.end (that's #<=> returns nil)" do
      range = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = double('non-comparable', '<=>': nil)
      expect(range.cover?(object)).to be false
    end
  end

  context 'given Range argument' do
    context 'other range is completely inside the self' do
      it 'returns true if self.begin < other.begin and self.end > other.end' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end > other.end' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin < other.begin and self.end == other.end' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be true
      end

      it "returns true if self.begin < other.begin and self.end < other.end but other.exclude_end? is true and the rightmost other's value <= self.end" do
        a = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(10))
        b = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(11), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end == other.end' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end > other.end' do
        a = described_class.new(nil, RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end' do
        a = described_class.new(nil, RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = described_class.new(nil, RangeSpecs::Element.new(10), true)
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end > other.end' do
        a = described_class.new(nil, RangeSpecs::Element.new(10))
        b = described_class.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = described_class.new(nil, RangeSpecs::Element.new(10), true)
        b = described_class.new(nil, RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be true
      end

      it "returns true if self is beginingless and self.end < other.end but other.exclude_end? is true and the rightmost other's value <= self.end" do
        a = described_class.new(nil, RangeSpecs::WithSucc.new(10))
        b = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(11), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is endless and self.begin < other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), nil)
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is endless and self.begin == other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), nil)
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), nil)
        b = described_class.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), nil)
        b = described_class.new(RangeSpecs::Element.new(0), nil)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin and self.excluded_end? is true and other.excluded_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), nil, true)
        b = described_class.new(RangeSpecs::Element.new(4), nil, true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin and self.excluded_end? is true and other.excluded_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), nil, true)
        b = described_class.new(RangeSpecs::Element.new(0), nil, true)
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is finit' do
        a = described_class.new(nil, nil)
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is beginingless' do
        a = described_class.new(nil, nil)
        b = described_class.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is endless' do
        a = described_class.new(nil, nil)
        b = described_class.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is finit' do # rubocop:disable RSpec/RepeatedExample
        a = described_class.new(nil, nil, true)
        b = described_class.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is beginingless' do # rubocop:disable RSpec/RepeatedExample
        a = described_class.new(nil, nil, true)
        b = described_class.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is endless and other.excluded_end? is true' do
        a = described_class.new(nil, nil, true)
        b = described_class.new(RangeSpecs::Element.new(4), nil, true)
        expect(a.cover?(b)).to be true
      end
    end

    context 'partially interleave' do
      it 'returns false if self.begin > other.begin, self.begin < other.end and self.end > other.end' do
        a = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin > other.begin, self.begin < other.end and self.end == other.end' do
        a = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin > other.begin, self.begin < other.end and self.end < other.end' do
        a = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin < other.begin and self.end > other.begin, self.end < other.end' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin < other.begin and self.end == other.end and self.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = described_class.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin < other.begin and self.end == other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end > other.begin but self.end < other.end' do
        a = described_class.new(nil, RangeSpecs::Element.new(6))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end == other.end but self.exclude_end? is true' do
        a = described_class.new(nil, RangeSpecs::Element.new(6), true)
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are beginingless but self.end < other.end' do
        a = described_class.new(nil, RangeSpecs::Element.new(6))
        b = described_class.new(nil, RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are beginingless and self.end == other.end but self.exclude_end? is true' do
        a = described_class.new(nil, RangeSpecs::Element.new(10), true)
        b = described_class.new(nil, RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is endless and self.begin > other.begin' do
        a = described_class.new(RangeSpecs::Element.new(4), nil)
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are endless and self.begin > other.begin' do
        a = described_class.new(RangeSpecs::Element.new(4), nil)
        b = described_class.new(RangeSpecs::Element.new(0), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are endless and self.begin == other.begin but self.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), nil, true)
        b = described_class.new(RangeSpecs::Element.new(0), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are endless and self.begin < other.begin but self.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), nil, true)
        b = described_class.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be false
      end

      it 'return false if self is (nil...nil) and other is endless' do
        a = described_class.new(nil, nil, true)
        b = described_class.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless and self.end == other.begin' do
        a = described_class.new(nil, RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless and self is endless and other.end == self.begin' do
        a = described_class.new(RangeSpecs::Element.new(10), nil)
        b = described_class.new(nil, RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end
    end

    context 'not interleave' do
      it 'returns false if self.begin > other.end' do
        a = described_class.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.end < other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = described_class.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless but self.end < other.begin' do
        a = described_class.new(nil, RangeSpecs::Element.new(4))
        b = described_class.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end == other.begin but self.exclude_end? is true' do
        a = described_class.new(nil, RangeSpecs::Element.new(4), true)
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless but self.end < other.begin' do
        a = described_class.new(nil, RangeSpecs::Element.new(0))
        b = described_class.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless and self.end == other.begin but self.exclude_end? is true' do
        a = described_class.new(nil, RangeSpecs::Element.new(10), true)
        b = described_class.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is endless but self.begin > other.end' do
        a = described_class.new(RangeSpecs::Element.new(10), nil)
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is endless but self.begin == other.end but other.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(6), nil)
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless but self.begin > other.end' do
        a = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = described_class.new(nil, RangeSpecs::Element.new(0))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless and self.begin == other.end but other.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        b = described_class.new(nil, RangeSpecs::Element.new(6), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless and self is endless and other.end == self.begin but other.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(10), nil)
        b = described_class.new(nil, RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is endless but self.end < other.begin' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = described_class.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is endless and self.end == other.begin but self.exclude_end? is true' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = described_class.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end
    end

    context 'backward ranges' do
      it 'returns false if other is backward and fits into the self' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(4))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is backward and other fits into the self' do
        a = described_class.new(RangeSpecs::Element.new(10), RangeSpecs::Element.new(0))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end
    end

    context 'empty ranges' do
      it 'returns false if other is empty and fits into the self' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = described_class.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(4), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is empty and equals other' do
        a = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
        b = described_class.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
        expect(a.cover?(b)).to be false
      end
    end

    it "returns false if an object boundaries aren't comparable with self boundaries" do
      a = described_class.new(0, 10)
      b = described_class.new('a', 'z')
      expect(a.cover?(b)).to be false
    end
  end
end
