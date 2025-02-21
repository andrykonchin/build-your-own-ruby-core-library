# -*- encoding: binary -*-
require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#cover?" do
  #it_behaves_like :range_cover_and_include, :cover?

  it "returns true if other is an element of self" do
    expect((0..5).cover?(2)).to eq(true)
    expect((-5..5).cover?(0)).to eq(true)
    expect((-1...1).cover?(10.5)).to eq(false)
    expect((-10..-2).cover?(-2.5)).to eq(true)
    expect(('C'..'X').cover?('M')).to eq(true)
    expect(('C'..'X').cover?('A')).to eq(false)
    expect(('B'...'W').cover?('W')).to eq(false)
    expect(('B'...'W').cover?('Q')).to eq(true)
    expect((0xffff..0xfffff).cover?(0xffffd)).to eq(true)
    expect((0xffff..0xfffff).cover?(0xfffd)).to eq(false)
    expect((0.5..2.4).cover?(2)).to eq(true)
    expect((0.5..2.4).cover?(2.5)).to eq(false)
    expect((0.5..2.4).cover?(2.4)).to eq(true)
    expect((0.5...2.4).cover?(2.4)).to eq(false)
  end

  it "returns true if other is an element of self for endless ranges" do
    expect(eval("(1..)").cover?(2.4)).to eq(true)
    expect(eval("(0.5...)").cover?(2.4)).to eq(true)
  end

  it "returns true if other is an element of self for beginless ranges" do
    expect((..10).cover?(2.4)).to eq(true)
    expect((...10.5).cover?(2.4)).to eq(true)
  end

  it "compares values using <=>" do
    rng = (1..5)
    m = double("int")
    expect(m).to receive(:coerce).and_return([1, 2])
    expect(m).to receive(:<=>).and_return(1)

    expect(rng.cover?(m)).to be false
  end

  it "raises an ArgumentError without exactly one argument" do
    expect{ (1..2).cover? }.to raise_error(ArgumentError)
    expect{ (1..2).cover?(1, 2) }.to raise_error(ArgumentError)
  end

  it "returns true if argument is equal to the first value of the range" do
    expect((0..5).cover?(0)).to be true
    expect(('f'..'s').cover?('f')).to be true
  end

  it "returns true if argument is equal to the last value of the range" do
    expect((0..5).cover?(5)).to be true
    expect((0...5).cover?(4)).to be true
    expect(('f'..'s').cover?('s')).to be true
  end

  it "returns true if argument is less than the last value of the range and greater than the first value" do
    expect((20..30).cover?(28)).to be true
    expect(('e'..'h').cover?('g')).to be true
  end

  it "returns true if argument is sole element in the range" do
    expect((30..30).cover?(30)).to be true
  end

  it "returns false if range is empty" do
    expect((30...30).cover?(30)).to be false
    expect((30...30).cover?(nil)).to be false
  end

  it "returns false if the range does not contain the argument" do
    expect(('A'..'C').cover?(20.9)).to be false
    expect(('A'...'C').cover?('C')).to be false
  end

  #it_behaves_like :range_cover, :cover?

  it "uses the range element's <=> to make the comparison" do
    a = double('a')
    expect(a).to receive(:<=>).twice.and_return(-1,-1)
    expect((a..'z').cover?('b')).to be true
  end

  it "uses a continuous inclusion test" do
    expect(('a'..'f').cover?('aa')).to be true
    expect(('a'..'f').cover?('babe')).to be true
    expect(('a'..'f').cover?('baby')).to be true
    expect(('a'..'f').cover?('ga')).to be false
    expect((-10..-2).cover?(-2.5)).to be true
  end

  describe "on string elements" do
    it "returns true if other is matched by element.succ" do
      expect(('a'..'c').cover?('b')).to be true
      expect(('a'...'c').cover?('b')).to be true
    end

    it "returns true if other is not matched by element.succ" do
      expect(('a'..'c').cover?('bc')).to be true
      expect(('a'...'c').cover?('bc')).to be true
    end
  end

  describe "with weird succ" do
    describe "when included end value" do
      before :each do
        @range = RangeSpecs::TenfoldSucc.new(1)..RangeSpecs::TenfoldSucc.new(99)
      end

      it "returns false if other is less than first element" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it "returns true if other is equal as first element" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it "returns true if other is matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it "returns true if other is not matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(2))).to be true
      end

      it "returns true if other is equal as last element but not matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(99))).to be true
      end

      it "returns false if other is greater than last element but matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end

    describe "when excluded end value" do
      before :each do
        @range = RangeSpecs::TenfoldSucc.new(1)...RangeSpecs::TenfoldSucc.new(99)
      end

      it "returns false if other is less than first element" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it "returns true if other is equal as first element" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it "returns true if other is matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it "returns true if other is not matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(2))).to be true
      end

      it "returns false if other is equal as last element but not matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it "returns false if other is greater than last element but matched by element.succ" do
        expect(@range.cover?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end
  end

  #it_behaves_like :range_cover_subrange, :cover?

  context "range argument" do
    it "accepts range argument" do
      expect((0..10).cover?((3..7))).to be true
      expect((0..10).cover?((3..15))).to be false
      expect((0..10).cover?((-2..7))).to be false

      expect((1.1..7.9).cover?((2.5..6.5))).to be true
      expect((1.1..7.9).cover?((2.5..8.5))).to be false
      expect((1.1..7.9).cover?((0.5..6.5))).to be false

      expect(('c'..'i').cover?(('d'..'f'))).to be true
      expect(('c'..'i').cover?(('d'..'z'))).to be false
      expect(('c'..'i').cover?(('a'..'f'))).to be false

      range_10_100 = RangeSpecs::TenfoldSucc.new(10)..RangeSpecs::TenfoldSucc.new(100)
      range_20_90 = RangeSpecs::TenfoldSucc.new(20)..RangeSpecs::TenfoldSucc.new(90)
      range_20_110 = RangeSpecs::TenfoldSucc.new(20)..RangeSpecs::TenfoldSucc.new(110)
      range_0_90 = RangeSpecs::TenfoldSucc.new(0)..RangeSpecs::TenfoldSucc.new(90)

      expect(range_10_100.cover?(range_20_90)).to be true
      expect(range_10_100.cover?(range_20_110)).to be false
      expect(range_10_100.cover?(range_0_90)).to be false
    end

    it "supports boundaries of different comparable types" do
      expect((0..10).cover?((3.1..7.9))).to be true
      expect((0..10).cover?((3.1..15.9))).to be false
      expect((0..10).cover?((-2.1..7.9))).to be false
    end

    it "returns false if types are not comparable" do
      expect((0..10).cover?(('a'..'z'))).to be false
      expect((0..10).cover?((RangeSpecs::TenfoldSucc.new(0)..RangeSpecs::TenfoldSucc.new(100)))).to be false
    end

    it "honors exclusion of right boundary (:exclude_end option)" do
      # Integer
      expect((0..10).cover?((0..10))).to be true
      expect((0...10).cover?((0...10))).to be true

      expect((0..10).cover?((0...10))).to be true
      expect((0...10).cover?((0..10))).to be false

      expect((0...11).cover?((0..10))).to be true
      expect((0..10).cover?((0...11))).to be true

      # Float
      expect((0..10.1).cover?((0..10.1))).to be true
      expect((0...10.1).cover?((0...10.1))).to be true

      expect((0..10.1).cover?((0...10.1))).to be true
      expect((0...10.1).cover?((0..10.1))).to be false

      expect((0...11.1).cover?((0..10.1))).to be true
      expect((0..10.1).cover?((0...11.1))).to be false
    end
  end

  it "allows self to be a beginless range" do
    expect((...10).cover?((3..7))).to be true
    expect((...10).cover?((3..15))).to be false

    expect((..7.9).cover?((2.5..6.5))).to be true
    expect((..7.9).cover?((2.5..8.5))).to be false

    expect((..'i').cover?(('d'..'f'))).to be true
    expect((..'i').cover?(('d'..'z'))).to be false
  end

  it "allows self to be a endless range" do
    expect(eval("(0...)").cover?((3..7))).to be true
    expect(eval("(5...)").cover?((3..15))).to be false

    expect(eval("(1.1..)").cover?((2.5..6.5))).to be true
    expect(eval("(3.3..)").cover?((2.5..8.5))).to be false

    expect(eval("('a'..)").cover?(('d'..'f'))).to be true
    expect(eval("('p'..)").cover?(('d'..'z'))).to be false
  end

  it "accepts beginless range argument" do
    expect((..10).cover?((...10))).to be true
    expect((0..10).cover?((...10))).to be false

    expect((1.1..7.9).cover?((...10.5))).to be false

    expect(('c'..'i').cover?((..'i'))).to be false
  end

  it "accepts endless range argument" do
    expect(eval("(0..)").cover?(eval("(0...)"))).to be true
    expect((0..10).cover?(eval("(0...)"))).to be false

    expect((1.1..7.9).cover?(eval("(0.8...)"))).to be false

    expect(('c'..'i').cover?(eval("('a'..)"))).to be false
  end

  it "covers U+9995 in the range U+0999..U+9999" do
    expect(("\u{999}".."\u{9999}").cover?("\u{9995}")).to be true
  end
end
