# -*- encoding: binary -*-

require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#cover?' do
  context 'given non-Range argument' do
    it 'returns true if object is between self.begin and self.end' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(5)
      expect(range.cover?(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(-5)
      expect(range.cover?(object)).to be false
    end

    it 'returns false if object is greater than self.end' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = RangeSpecs::Element.new(10)
      expect(range.cover?(object)).to be false
    end

    it 'ignores end if excluded end' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6), true)
      object = RangeSpecs::Element.new(6)
      expect(range.cover?(object)).to be false
    end

    it 'returns true if argument is a single element in the range' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0))
      object = RangeSpecs::Element.new(0)
      expect(range.cover?(object)).to be true
    end

    it 'returns false if range is empty' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
      object = RangeSpecs::Element.new(0)
      expect(range.cover?(object)).to be false
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      expect(range.cover?(Object.new)).to be false
    end

    context 'beginingless range' do
      it 'returns false if object is greater than self.end' do
        range = Range.new(nil, RangeSpecs::Element.new(6))
        object = RangeSpecs::Element.new(10)
        expect(range.cover?(object)).to be false
      end

      it 'returns true if object is smaller than self.end' do
        range = Range.new(nil, RangeSpecs::Element.new(6))
        object = RangeSpecs::Element.new(0)
        expect(range.cover?(object)).to be true
      end
    end

    context 'endless range' do
      it 'returns true if object is greater than self.begin' do
        range = Range.new(RangeSpecs::Element.new(0), nil)
        object = RangeSpecs::Element.new(10)
        expect(range.cover?(object)).to be true
      end

      it 'returns false if object is smaller than self.begin' do
        range = Range.new(RangeSpecs::Element.new(0), nil)
        object = RangeSpecs::Element.new(-10)
        expect(range.cover?(object)).to be false
      end
    end

    it 'returns true on any value for (nil..nil)' do
      expect(Range.new(nil, nil).cover?(Object.new)).to be true
    end

    it "returns false if object isn't comparable with self.begin and self.end (that's #<=> returns nil)" do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
      object = double('non-comparable', '<=>': nil)
      expect(range.cover?(object)).to be false
    end
  end

  context 'given Range argument' do
    context 'other range is completely inside the self' do
      it 'returns true if self.begin < other.begin and self.end > other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end > other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin < other.begin and self.end == other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end == other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self.begin == other.begin and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is beginingless and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end > other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are beginingless and self.end == other.end and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(nil, RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is endless and self.begin < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self is endless and self.begin == other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), nil)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin < other.begin and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil, true)
        expect(a.cover?(b)).to be true
      end

      it 'returns true if self and other are endless and self.begin == other.begin and self.excluded_end? is true and other.excluded_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(0), nil, true)
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is finit' do
        a = Range.new(nil, nil)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is beginingless' do
        a = Range.new(nil, nil)
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil..nil) and other is endless' do
        a = Range.new(nil, nil)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is finit' do
        a = Range.new(nil, nil, true)
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is beginingless' do
        a = Range.new(nil, nil, true)
        b = Range.new(nil, RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be true
      end

      it 'return true if self is (nil...nil) and other is endless and other.excluded_end? is true' do
        a = Range.new(nil, nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil, true)
        expect(a.cover?(b)).to be true
      end
    end

    context 'partially interleave' do
      it 'returns false if self.begin > other.begin, self.begin < other.end and self.end > other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin > other.begin, self.begin < other.end and self.end == other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin > other.begin, self.begin < other.end and self.end < other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin < other.begin and self.end > other.begin, self.end < other.end' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin < other.begin and self.end == other.end and self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.begin < other.begin and self.end == other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end > other.begin but self.end < other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(6))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end == other.end but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(6), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are beginingless but self.end < other.end' do
        a = Range.new(nil, RangeSpecs::Element.new(6))
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are beginingless and self.end == other.end but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is endless and self.begin > other.begin' do
        a = Range.new(RangeSpecs::Element.new(4), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are endless and self.begin > other.begin' do
        a = Range.new(RangeSpecs::Element.new(4), nil)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are endless and self.begin == other.begin but self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(0), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self and other are endless and self.begin < other.begin but self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be false
      end

      it 'return false if self is (nil...nil) and other is endless' do
        a = Range.new(nil, nil, true)
        b = Range.new(RangeSpecs::Element.new(4), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless and self.end == other.begin' do
        a = Range.new(nil, RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless and self is endless and other.end == self.begin' do
        a = Range.new(RangeSpecs::Element.new(10), nil)
        b = Range.new(nil, RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end
    end

    context 'not interleave' do
      it 'returns false if self.begin > other.end' do
        a = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self.end < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless but self.end < other.begin' do
        a = Range.new(nil, RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and self.end == other.begin but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(4), true)
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless but self.end < other.begin' do
        a = Range.new(nil, RangeSpecs::Element.new(0))
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is beginingless and other is endless and self.end == other.begin but self.exclude_end? is true' do
        a = Range.new(nil, RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is endless but self.begin > other.end' do
        a = Range.new(RangeSpecs::Element.new(10), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is endless but self.begin == other.end but other.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(6), nil)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless but self.begin > other.end' do
        a = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(0))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless and self.begin == other.end but other.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(10))
        b = Range.new(nil, RangeSpecs::Element.new(6), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is beginingless and self is endless and other.end == self.begin but other.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(10), nil)
        b = Range.new(nil, RangeSpecs::Element.new(10), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is endless but self.end < other.begin' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(4))
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if other is endless and self.end == other.begin but self.exclude_end? is true' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10), true)
        b = Range.new(RangeSpecs::Element.new(10), nil)
        expect(a.cover?(b)).to be false
      end
    end

    context 'backward ranges' do
      it 'returns false if other is backward and fits into the self' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(6), RangeSpecs::Element.new(4))
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is backward and other fits into the self' do
        a = Range.new(RangeSpecs::Element.new(10), RangeSpecs::Element.new(0))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(6))
        expect(a.cover?(b)).to be false
      end
    end

    context 'empty ranges' do
      it 'returns false if other is empty and fits into the self' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(10))
        b = Range.new(RangeSpecs::Element.new(4), RangeSpecs::Element.new(4), true)
        expect(a.cover?(b)).to be false
      end

      it 'returns false if self is empty and equals other' do
        a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
        b = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(0), true)
        expect(a.cover?(b)).to be false
      end
    end
  end
end

# rubocop: disable
# TODO: remove after implementation
RSpec.describe 'Range#cover?' do
  # it_behaves_like :range_cover_and_include, :cover?

  it 'returns true if other is an element of self' do
    expect(Range.new(0, 5).cover?(2)).to be(true)
    expect(Range.new(-5, 5).cover?(0)).to be(true)
    expect(Range.new(-1, 1, true).cover?(10.5)).to be(false)
    expect(Range.new(-10, -2).cover?(-2.5)).to be(true)
    expect(Range.new('C', 'X').cover?('M')).to be(true)
    expect(Range.new('C', 'X').cover?('A')).to be(false)
    expect(Range.new('B', 'W', true).cover?('W')).to be(false)
    expect(Range.new('B', 'W', true).cover?('Q')).to be(true)
    expect(Range.new(0xffff, 0xfffff).cover?(0xffffd)).to be(true)
    expect(Range.new(0xffff, 0xfffff).cover?(0xfffd)).to be(false)
    expect(Range.new(0.5, 2.4).cover?(2)).to be(true)
    expect(Range.new(0.5, 2.4).cover?(2.5)).to be(false)
    expect(Range.new(0.5, 2.4).cover?(2.4)).to be(true)
    expect(Range.new(0.5, 2.4, true).cover?(2.4)).to be(false)
  end

  it 'returns true if other is an element of self for endless ranges' do
    expect(Range.new(1, nil).cover?(2.4)).to be(true)
    expect(Range.new(0.5, nil, true).cover?(2.4)).to be(true)
  end

  it 'returns true if other is an element of self for beginless ranges' do
    expect(Range.new(nil, 10).cover?(2.4)).to be(true)
    expect(Range.new(nil, 10.5, true).cover?(2.4)).to be(true)
  end

  it 'compares values using <=>' do
    rng = Range.new(1, 5)
    m = double('int')
    expect(m).to receive(:coerce).and_return([1, 2])
    expect(m).to receive(:<=>).and_return(1)

    expect(rng.cover?(m)).to be false
  end

  it 'raises an ArgumentError without exactly one argument' do
    expect { Range.new(1, 2).cover? }.to raise_error(ArgumentError)
    expect { Range.new(1, 2).cover?(1, 2) }.to raise_error(ArgumentError)
  end

  it 'returns true if argument is equal to the first value of the range' do
    expect(Range.new(0, 5).cover?(0)).to be true
    expect(Range.new('f', 's').cover?('f')).to be true
  end

  it 'returns true if argument is equal to the last value of the range' do
    expect(Range.new(0, 5).cover?(5)).to be true
    expect(Range.new(0, 5, true).cover?(4)).to be true
    expect(Range.new('f', 's').cover?('s')).to be true
  end

  it 'returns true if argument is less than the last value of the range and greater than the first value' do
    expect(Range.new(20, 30).cover?(28)).to be true
    expect(Range.new('e', 'h').cover?('g')).to be true
  end

  it 'returns true if argument is sole element in the range' do
    expect(Range.new(30, 30).cover?(30)).to be true
  end

  it 'returns false if range is empty' do
    expect(Range.new(30, 30, true).cover?(30)).to be false
    expect(Range.new(30, 30, true).cover?(nil)).to be false
  end

  it 'returns false if the range does not contain the argument' do
    expect(Range.new('A', 'C').cover?(20.9)).to be false
    expect(Range.new('A', 'C', true).cover?('C')).to be false
  end

  # it_behaves_like :range_cover, :cover?

  it "uses the range element's <=> to make the comparison" do
    a = double('a')
    expect(a).to receive(:<=>).twice.and_return(-1, -1)
    expect(Range.new(a, 'z').cover?('b')).to be true
  end

  it 'uses a continuous inclusion test' do
    expect(Range.new('a', 'f').cover?('aa')).to be true
    expect(Range.new('a', 'f').cover?('babe')).to be true
    expect(Range.new('a', 'f').cover?('baby')).to be true
    expect(Range.new('a', 'f').cover?('ga')).to be false
    expect(Range.new(-10, -2).cover?(-2.5)).to be true
  end

  describe 'on string elements' do
    it 'returns true if other is matched by element.succ' do
      expect(Range.new('a', 'c').cover?('b')).to be true
      expect(Range.new('a', 'c', true).cover?('b')).to be true
    end

    it 'returns true if other is not matched by element.succ' do
      expect(Range.new('a', 'c').cover?('bc')).to be true
      expect(Range.new('a', 'c', true).cover?('bc')).to be true
    end
  end

  describe 'with weird succ' do
    describe 'when included end value' do
      before do
        @range = Range.new(RangeSpecs::TenfoldSucc.new(1), RangeSpecs::TenfoldSucc.new(99))
      end

      it 'returns false if other is less than first element' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it 'returns true if other is equal as first element' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it 'returns true if other is matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it 'returns true if other is not matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(2))).to be true
      end

      it 'returns true if other is equal as last element but not matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(99))).to be true
      end

      it 'returns false if other is greater than last element but matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end

    describe 'when excluded end value' do
      before do
        @range = Range.new(RangeSpecs::TenfoldSucc.new(1), RangeSpecs::TenfoldSucc.new(99), true)
      end

      it 'returns false if other is less than first element' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it 'returns true if other is equal as first element' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it 'returns true if other is matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it 'returns true if other is not matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(2))).to be true
      end

      it 'returns false if other is equal as last element but not matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it 'returns false if other is greater than last element but matched by element.succ' do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end
  end

  # it_behaves_like :range_cover_subrange, :cover?

  context 'range argument' do
    it 'accepts range argument' do
      expect(Range.new(0, 10).cover?(Range.new(3, 7))).to be true
      expect(Range.new(0, 10).cover?(Range.new(3, 15))).to be false
      expect(Range.new(0, 10).cover?(Range.new(-2, 7))).to be false

      expect(Range.new(1.1, 7.9).cover?(Range.new(2.5, 6.5))).to be true
      expect(Range.new(1.1, 7.9).cover?(Range.new(2.5, 8.5))).to be false
      expect(Range.new(1.1, 7.9).cover?(Range.new(0.5, 6.5))).to be false

      expect(Range.new('c', 'i').cover?(Range.new('d', 'f'))).to be true
      expect(Range.new('c', 'i').cover?(Range.new('d', 'z'))).to be false
      expect(Range.new('c', 'i').cover?(Range.new('a', 'f'))).to be false

      range_10_100 = Range.new(RangeSpecs::TenfoldSucc.new(10), RangeSpecs::TenfoldSucc.new(100))
      range_20_90 =  Range.new(RangeSpecs::TenfoldSucc.new(20), RangeSpecs::TenfoldSucc.new(90))
      range_20_110 = Range.new(RangeSpecs::TenfoldSucc.new(20), RangeSpecs::TenfoldSucc.new(110))
      range_0_90 =   Range.new(RangeSpecs::TenfoldSucc.new(0), RangeSpecs::TenfoldSucc.new(90))

      expect(range_10_100.cover?(range_20_90)).to be true
      expect(range_10_100.cover?(range_20_110)).to be false
      expect(range_10_100.cover?(range_0_90)).to be false
    end

    it 'supports boundaries of different comparable types' do
      expect(Range.new(0, 10).cover?(Range.new(3.1, 7.9))).to be true
      expect(Range.new(0, 10).cover?(Range.new(3.1, 15.9))).to be false
      expect(Range.new(0, 10).cover?(Range.new(-2.1, 7.9))).to be false
    end

    it 'returns false if types are not comparable' do
      expect(Range.new(0, 10).cover?(Range.new('a', 'z'))).to be false
      expect(Range.new(0, 10).cover?(Range.new(RangeSpecs::TenfoldSucc.new(0), RangeSpecs::TenfoldSucc.new(100)))).to be false
    end

    it 'honors exclusion of right boundary (:exclude_end option)' do
      # Integer
      expect(Range.new(0, 10).cover?(Range.new(0, 10))).to be true
      expect(Range.new(0, 10, true).cover?(Range.new(0, 10, true))).to be true

      expect(Range.new(0, 10).cover?(Range.new(0, 10, true))).to be true
      expect(Range.new(0, 10, true).cover?(Range.new(0, 10))).to be false

      expect(Range.new(0, 11, true).cover?(Range.new(0, 10))).to be true
      expect(Range.new(0, 10).cover?(Range.new(0, 11, true))).to be true

      # Float
      expect(Range.new(0, 10.1).cover?(Range.new(0, 10.1))).to be true
      expect(Range.new(0, 10.1, true).cover?(Range.new(0, 10.1, true))).to be true

      expect(Range.new(0, 10.1).cover?(Range.new(0, 10.1, true))).to be true
      expect(Range.new(0, 10.1, true).cover?(Range.new(0, 10.1))).to be false

      expect(Range.new(0, 11.1, true).cover?(Range.new(0, 10.1))).to be true
      expect(Range.new(0, 10.1).cover?(Range.new(0, 11.1, true))).to be false
    end
  end

  it 'allows self to be a beginless range' do
    expect(Range.new(nil, 10, true).cover?(Range.new(3, 7))).to be true
    expect(Range.new(nil, 10, true).cover?(Range.new(3, 15))).to be false

    expect(Range.new(nil, 7.9).cover?(Range.new(2.5, 6.5))).to be true
    expect(Range.new(nil, 7.9).cover?(Range.new(2.5, 8.5))).to be false

    expect(Range.new(nil, 'i').cover?(Range.new('d', 'f'))).to be true
    expect(Range.new(nil, 'i').cover?(Range.new('d', 'z'))).to be false
  end

  it 'allows self to be a endless range' do
    expect(Range.new(0, nil, true).cover?(Range.new(3, 7))).to be true
    expect(Range.new(5, nil, true).cover?(Range.new(3, 15))).to be false

    expect(Range.new(1.1, nil).cover?(Range.new(2.5, 6.5))).to be true
    expect(Range.new(3.3, nil).cover?(Range.new(2.5, 8.5))).to be false

    expect(Range.new('a', nil).cover?(Range.new('d', 'f'))).to be true
    expect(Range.new('p', nil).cover?(Range.new('d', 'z'))).to be false
  end

  it 'accepts beginless range argument' do
    expect(Range.new(nil, 10).cover?(Range.new(nil, 10, true))).to be true
    expect(Range.new(0, 10).cover?(Range.new(nil, 10, true))).to be false

    expect(Range.new(1.1, 7.9).cover?(Range.new(nil, 10.5, true))).to be false

    expect(Range.new('c', 'i').cover?(Range.new(nil, 'i'))).to be false
  end

  it 'accepts endless range argument' do
    expect(Range.new(0, nil).cover?(Range.new(0, nil, true))).to be true
    expect(Range.new(0, 10).cover?(Range.new(0, nil, true))).to be false

    expect(Range.new(1.1, 7.9).cover?(Range.new(0.8, nil, true))).to be false

    expect(Range.new('c', 'i').cover?(Range.new('a', nil))).to be false
  end

  it 'covers U+9995 in the range U+0999..U+9999' do
    expect(Range.new("\u{999}", "\u{9999}").cover?("\u{9995}")).to be true
  end
end
# rubocop: enable
