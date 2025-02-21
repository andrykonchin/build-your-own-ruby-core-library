# -*- encoding: binary -*-

require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#include?' do
  it 'returns whether object is an element of self using #== to compare' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.include?(RangeSpecs::WithSucc.new(2))).to be true
    expect(range.include?(RangeSpecs::WithSucc.new(5))).to be false
  end

  it 'ignores self.end if excluded end' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    expect(range.include?(RangeSpecs::WithSucc.new(4))).to be false
  end

  it 'returns false if backward range' do
    range = Range.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
    expect(range.include?(RangeSpecs::WithSucc.new(2))).to be false
  end

  it 'returns false if empty range' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(1), true)
    expect(range.include?(RangeSpecs::WithSucc.new(1))).to be false
  end

  context 'Numeric ranges' do
    it 'returns true if object is between self.begin and self.end' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = RangeSpecs::Number.new(5)
      expect(range.include?(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = RangeSpecs::Number.new(-5)
      expect(range.include?(object)).to be false
    end

    it 'returns false if object is greater than self.end' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = RangeSpecs::Number.new(10)
      expect(range.include?(object)).to be false
    end

    it 'ignores end if excluded end' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6), true)
      object = RangeSpecs::Number.new(6)
      expect(range.include?(object)).to be false
    end

    it 'returns true if argument is a single element in the range' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0))
      object = RangeSpecs::Number.new(0)
      expect(range.include?(object)).to be true
    end

    it 'returns false if range is empty' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0), true)
      object = RangeSpecs::Number.new(0)
      expect(range.include?(object)).to be false
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      expect(range.include?(Object.new)).to be false
    end

    context 'beginingless range' do
      it 'returns false if object is greater than self.end' do
        range = Range.new(nil, RangeSpecs::Number.new(6))
        object = RangeSpecs::Number.new(10)
        expect(range.include?(object)).to be false
      end

      it 'returns true if object is smaller than self.end' do
        range = Range.new(nil, RangeSpecs::Number.new(6))
        object = RangeSpecs::Number.new(0)
        expect(range.include?(object)).to be true
      end
    end

    context 'endless range' do
      it 'returns true if object is greater than self.begin' do
        range = Range.new(RangeSpecs::Number.new(0), nil)
        object = RangeSpecs::Number.new(10)
        expect(range.include?(object)).to be true
      end

      it 'returns false if object is smaller than self.begin' do
        range = Range.new(RangeSpecs::Number.new(0), nil)
        object = RangeSpecs::Number.new(-10)
        expect(range.include?(object)).to be false
      end
    end

    it "returns false if object isn't comparable with self.begin and self.end (that's #<=> returns nil)" do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = double('non-comparable', '<=>': nil)
      expect(range.include?(object)).to be false
    end
  end

  context 'Time ranges' do
    # Use 1700000000 as a base timestamp.
    #   Time.at(1700000000) # => 2023-11-15 00:13:20 +0200

    it 'returns true if object is between self.begin and self.end' do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = Time.at(1_700_000_000 + 5)
      expect(range.include?(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = Time.at(1_700_000_000 - 5)
      expect(range.include?(object)).to be false
    end

    it 'returns false if object is greater than self.end' do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = Time.at(1_700_000_000 + 10)
      expect(range.include?(object)).to be false
    end

    it 'ignores end if excluded end' do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6), true)
      object = Time.at(1_700_000_000 + 6)
      expect(range.include?(object)).to be false
    end

    it 'returns true if argument is a single element in the range' do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000))
      object = Time.at(1_700_000_000)
      expect(range.include?(object)).to be true
    end

    it 'returns false if range is empty' do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000), true)
      object = Time.at(1_700_000_000)
      expect(range.include?(object)).to be false
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      expect(range.include?(Object.new)).to be false
    end

    context 'beginingless range' do
      it 'returns false if object is greater than self.end' do
        range = Range.new(nil, Time.at(1_700_000_000 + 6))
        object = Time.at(1_700_000_000 + 10)
        expect(range.include?(object)).to be false
      end

      it 'returns true if object is smaller than self.end' do
        range = Range.new(nil, Time.at(1_700_000_000 + 6))
        object = Time.at(1_700_000_000)
        expect(range.include?(object)).to be true
      end
    end

    context 'endless range' do
      it 'returns true if object is greater than self.begin' do
        range = Range.new(Time.at(1_700_000_000), nil)
        object = Time.at(1_700_000_000 + 10)
        expect(range.include?(object)).to be true
      end

      it 'returns false if object is smaller than self.begin' do
        range = Range.new(Time.at(1_700_000_000 + 10), nil)
        object = Time.at(1_700_000_000)
        expect(range.include?(object)).to be false
      end
    end

    it "returns false if object isn't comparable with self.begin and self.end (that's #<=> returns nil)" do
      range = Range.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = double('non-comparable', '<=>': nil)
      expect(range.include?(object)).to be false
    end
  end

  it 'raises TypeError for (nil..nil)' do
    expect {
      Range.new(nil, nil).include?(Object.new)
    }.to raise_error(TypeError, 'cannot determine inclusion in beginless/endless ranges')
  end
end

# rubocop: disable
# TODO: remove after implementation
RSpec.describe 'Range#include?' do
  # it_behaves_like :range_cover_and_include, :include?

  it 'returns true if other is an element of self' do
    expect(Range.new(0, 5).include?(2)).to be(true)
    expect(Range.new(-5, 5).include?(0)).to be(true)
    expect(Range.new(-1, 1, true).include?(10.5)).to be(false)
    expect(Range.new(-10, -2).include?(-2.5)).to be(true)
    expect(Range.new('C', 'X').include?('M')).to be(true)
    expect(Range.new('C', 'X').include?('A')).to be(false)
    expect(Range.new('B', 'W', true).include?('W')).to be(false)
    expect(Range.new('B', 'W', true).include?('Q')).to be(true)
    expect(Range.new(0xffff, 0xfffff).include?(0xffffd)).to be(true)
    expect(Range.new(0xffff, 0xfffff).include?(0xfffd)).to be(false)
    expect(Range.new(0.5, 2.4).include?(2)).to be(true)
    expect(Range.new(0.5, 2.4).include?(2.5)).to be(false)
    expect(Range.new(0.5, 2.4).include?(2.4)).to be(true)
    expect(Range.new(0.5, 2.4, true).include?(2.4)).to be(false)
  end

  it 'returns true if other is an element of self for endless ranges' do
    expect(Range.new(1, nil).include?(2.4)).to be(true)
    expect(Range.new(0.5, nil, true).include?(2.4)).to be(true)
  end

  it 'returns true if other is an element of self for beginless ranges' do
    expect(Range.new(nil, 10).include?(2.4)).to be(true)
    expect(Range.new(nil, 10.5, true).include?(2.4)).to be(true)
  end

  it 'compares values using <=>' do
    rng = Range.new(1, 5)
    m = double('int')
    expect(m).to receive(:coerce).and_return([1, 2])
    expect(m).to receive(:<=>).and_return(1)

    expect(rng.include?(m)).to be false
  end

  it 'raises an ArgumentError without exactly one argument' do
    expect { Range.new(1, 2).include? }.to raise_error(ArgumentError)
    expect { Range.new(1, 2).include?(1, 2) }.to raise_error(ArgumentError)
  end

  it 'returns true if argument is equal to the first value of the range' do
    expect(Range.new(0, 5).include?(0)).to be true
    expect(Range.new('f', 's').include?('f')).to be true
  end

  it 'returns true if argument is equal to the last value of the range' do
    expect(Range.new(0, 5).include?(5)).to be true
    expect(Range.new(0, 5, true).include?(4)).to be true
    expect(Range.new('f', 's').include?('s')).to be true
  end

  it 'returns true if argument is less than the last value of the range and greater than the first value' do
    expect(Range.new(20, 30).include?(28)).to be true
    expect(Range.new('e', 'h').include?('g')).to be true
  end

  it 'returns true if argument is sole element in the range' do
    expect(Range.new(30, 30).include?(30)).to be true
  end

  it 'returns false if range is empty' do
    expect(Range.new(30, 30, true).include?(30)).to be false
    expect(Range.new(30, 30, true).include?(nil)).to be false
  end

  it 'returns false if the range does not contain the argument' do
    expect(Range.new('A', 'C').include?(20.9)).to be false
    expect(Range.new('A', 'C', true).include?('C')).to be false
  end

  # it_behaves_like :range_include, :include?

  describe 'on string elements' do
    it 'returns true if other is matched by element.succ' do
      expect(Range.new('a', 'c').include?('b')).to be true
      expect(Range.new('a', 'c', true).include?('b')).to be true
    end

    it 'returns false if other is not matched by element.succ' do
      expect(Range.new('a', 'c').include?('bc')).to be false
      expect(Range.new('a', 'c', true).include?('bc')).to be false
    end
  end

  describe 'with weird succ' do
    describe 'when included end value' do
      before do
        @range = Range.new(RangeSpecs::TenfoldSucc.new(1), RangeSpecs::TenfoldSucc.new(99))
      end

      it 'returns false if other is less than first element' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it 'returns true if other is equal as first element' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it 'returns true if other is matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it 'returns false if other is not matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(2))).to be false
      end

      it 'returns false if other is equal as last element but not matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it 'returns false if other is greater than last element but matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end

    describe 'when excluded end value' do
      before do
        @range = Range.new(RangeSpecs::TenfoldSucc.new(1), RangeSpecs::TenfoldSucc.new(99), true)
      end

      it 'returns false if other is less than first element' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it 'returns true if other is equal as first element' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it 'returns true if other is matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it 'returns false if other is not matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(2))).to be false
      end

      it 'returns false if other is equal as last element but not matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it 'returns false if other is greater than last element but matched by element.succ' do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end
  end

  describe 'with Time endpoints' do
    it 'uses cover? logic' do
      now = Time.now
      range = Range.new(now, (now + 60))

      expect(range.include?(now)).to be(true)
      expect(range.include?(now - 1)).to be(false)
      expect(range.include?(now + 60)).to be(true)
      expect(range.include?(now + 61)).to be(false)
    end
  end

  it 'does not include U+9995 in the range U+0999..U+9999' do
    expect(Range.new("\u{999}", "\u{9999}").include?("\u{9995}")).to be false
  end
end
# rubocop: enable
