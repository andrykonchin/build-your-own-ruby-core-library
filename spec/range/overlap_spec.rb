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

      it 'returns true if self is beginingless and self.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self is endless and self.begin < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(4), nil)
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
    end

    context 'self is completely inside the other range' do
      it 'returns true if other.begin < self.begin and other.end > self.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if other is beginingless and other.end > self.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if other and self are beginingless and other.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(6))
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if other is endless and other.begin < self.begin' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'returns true if other and self are endless and other.begin < self.begin' do
        a = Range.new(RangeSpecs::Element.new(4), nil)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.overlap?(b)).to be true
      end

      it 'return true if other is (nil..nil) and self is finit' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = Range.new(nil, nil)
        expect(a.overlap?(b)).to be true
      end

      it 'return true if other is (nil..nil) and self is beginingless' do
        a = Range.new(nil, RangeSpecs::Element.new(6))
        b = Range.new(nil, nil)
        expect(a.overlap?(b)).to be true
      end

      it 'return true if other is (nil..nil) and self is endless' do
        a = Range.new(RangeSpecs::Element.new(4), nil)
        b = Range.new(nil, nil)
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

      it 'returns false if self is empty and fits into the other' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(4), true)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
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
