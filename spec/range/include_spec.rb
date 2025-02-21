# -*- encoding: binary -*-
require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#include?" do
  #it_behaves_like :range_cover_and_include, :include?

  it "returns true if other is an element of self" do
    expect((0..5).include?(2)).to eq(true)
    expect((-5..5).include?(0)).to eq(true)
    expect((-1...1).include?(10.5)).to eq(false)
    expect((-10..-2).include?(-2.5)).to eq(true)
    expect(('C'..'X').include?('M')).to eq(true)
    expect(('C'..'X').include?('A')).to eq(false)
    expect(('B'...'W').include?('W')).to eq(false)
    expect(('B'...'W').include?('Q')).to eq(true)
    expect((0xffff..0xfffff).include?(0xffffd)).to eq(true)
    expect((0xffff..0xfffff).include?(0xfffd)).to eq(false)
    expect((0.5..2.4).include?(2)).to eq(true)
    expect((0.5..2.4).include?(2.5)).to eq(false)
    expect((0.5..2.4).include?(2.4)).to eq(true)
    expect((0.5...2.4).include?(2.4)).to eq(false)
  end

  it "returns true if other is an element of self for endless ranges" do
    expect(eval("(1..)").include?(2.4)).to eq(true)
    expect(eval("(0.5...)").include?(2.4)).to eq(true)
  end

  it "returns true if other is an element of self for beginless ranges" do
    expect((..10).include?(2.4)).to eq(true)
    expect((...10.5).include?(2.4)).to eq(true)
  end

  it "compares values using <=>" do
    rng = (1..5)
    m = double("int")
    expect(m).to receive(:coerce).and_return([1, 2])
    expect(m).to receive(:<=>).and_return(1)

    expect(rng.include?(m)).to be false
  end

  it "raises an ArgumentError without exactly one argument" do
    expect{ (1..2).include? }.to raise_error(ArgumentError)
    expect{ (1..2).include?(1, 2) }.to raise_error(ArgumentError)
  end

  it "returns true if argument is equal to the first value of the range" do
    expect((0..5).include?(0)).to be true
    expect(('f'..'s').include?('f')).to be true
  end

  it "returns true if argument is equal to the last value of the range" do
    expect((0..5).include?(5)).to be true
    expect((0...5).include?(4)).to be true
    expect(('f'..'s').include?('s')).to be true
  end

  it "returns true if argument is less than the last value of the range and greater than the first value" do
    expect((20..30).include?(28)).to be true
    expect(('e'..'h').include?('g')).to be true
  end

  it "returns true if argument is sole element in the range" do
    expect((30..30).include?(30)).to be true
  end

  it "returns false if range is empty" do
    expect((30...30).include?(30)).to be false
    expect((30...30).include?(nil)).to be false
  end

  it "returns false if the range does not contain the argument" do
    expect(('A'..'C').include?(20.9)).to be false
    expect(('A'...'C').include?('C')).to be false
  end

  #it_behaves_like :range_include, :include?

  describe "on string elements" do
    it "returns true if other is matched by element.succ" do
      expect(('a'..'c').include?('b')).to be true
      expect(('a'...'c').include?('b')).to be true
    end

    it "returns false if other is not matched by element.succ" do
      expect(('a'..'c').include?('bc')).to be false
      expect(('a'...'c').include?('bc')).to be false
    end
  end

  describe "with weird succ" do
    describe "when included end value" do
      before :each do
        @range = RangeSpecs::TenfoldSucc.new(1)..RangeSpecs::TenfoldSucc.new(99)
      end

      it "returns false if other is less than first element" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it "returns true if other is equal as first element" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it "returns true if other is matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it "returns false if other is not matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(2))).to be false
      end

      it "returns false if other is equal as last element but not matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it "returns false if other is greater than last element but matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end

    describe "when excluded end value" do
      before :each do
        @range = RangeSpecs::TenfoldSucc.new(1)...RangeSpecs::TenfoldSucc.new(99)
      end

      it "returns false if other is less than first element" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it "returns true if other is equal as first element" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it "returns true if other is matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it "returns false if other is not matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(2))).to be false
      end

      it "returns false if other is equal as last element but not matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it "returns false if other is greater than last element but matched by element.succ" do
        expect(@range.include?(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end
  end

  describe "with Time endpoints" do
    it "uses cover? logic" do
      now = Time.now
      range = (now..(now + 60))

      expect(range.include?(now)).to eq(true)
      expect(range.include?(now - 1)).to eq(false)
      expect(range.include?(now + 60)).to eq(true)
      expect(range.include?(now + 61)).to eq(false)
    end
  end

  it "does not include U+9995 in the range U+0999..U+9999" do
    expect(("\u{999}".."\u{9999}").include?("\u{9995}")).to be false
  end
end
