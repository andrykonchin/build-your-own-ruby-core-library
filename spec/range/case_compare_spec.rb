require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#===" do
  it "returns the result of calling #cover? on self" do
    range = RangeSpecs::WithoutSucc.new(0)..RangeSpecs::WithoutSucc.new(10)
    expect(range === RangeSpecs::WithoutSucc.new(2)).to eq(true)
  end

  #it_behaves_like :range_cover_and_include, :===

  it "returns true if other is an element of self" do
    expect((0..5).===(2)).to eq(true)
    expect((-5..5).===(0)).to eq(true)
    expect((-1...1).===(10.5)).to eq(false)
    expect((-10..-2).===(-2.5)).to eq(true)
    expect(('C'..'X').===('M')).to eq(true)
    expect(('C'..'X').===('A')).to eq(false)
    expect(('B'...'W').===('W')).to eq(false)
    expect(('B'...'W').===('Q')).to eq(true)
    expect((0xffff..0xfffff).===(0xffffd)).to eq(true)
    expect((0xffff..0xfffff).===(0xfffd)).to eq(false)
    expect((0.5..2.4).===(2)).to eq(true)
    expect((0.5..2.4).===(2.5)).to eq(false)
    expect((0.5..2.4).===(2.4)).to eq(true)
    expect((0.5...2.4).===(2.4)).to eq(false)
  end

  it "returns true if other is an element of self for endless ranges" do
    expect(eval("(1..)").===(2.4)).to eq(true)
    expect(eval("(0.5...)").===(2.4)).to eq(true)
  end

  it "returns true if other is an element of self for beginless ranges" do
    expect((..10).===(2.4)).to eq(true)
    expect((...10.5).===(2.4)).to eq(true)
  end

  it "compares values using <=>" do
    rng = (1..5)
    m = double("int")
    expect(m).to receive(:coerce).and_return([1, 2])
    expect(m).to receive(:<=>).and_return(1)

    expect(rng.===(m)).to be false
  end

  it "raises an ArgumentError without exactly one argument" do
    expect{ (1..2).===() }.to raise_error(ArgumentError)
    expect{ (1..2).===(1, 2) }.to raise_error(ArgumentError)
  end

  it "returns true if argument is equal to the first value of the range" do
    expect((0..5).===(0)).to be true
    expect(('f'..'s').===('f')).to be true
  end

  it "returns true if argument is equal to the last value of the range" do
    expect((0..5).===(5)).to be true
    expect((0...5).===(4)).to be true
    expect(('f'..'s').===('s')).to be true
  end

  it "returns true if argument is less than the last value of the range and greater than the first value" do
    expect((20..30).===(28)).to be true
    expect(('e'..'h').===('g')).to be true
  end

  it "returns true if argument is sole element in the range" do
    expect((30..30).===(30)).to be true
  end

  it "returns false if range is empty" do
    expect((30...30).===(30)).to be false
    expect((30...30).===(nil)).to be false
  end

  it "returns false if the range does not contain the argument" do
    expect(('A'..'C').===(20.9)).to be false
    expect(('A'...'C').===('C')).to be false
  end

  #it_behaves_like :range_cover, :===

  it "uses the range element's <=> to make the comparison" do
    a = double('a')
    expect(a).to receive(:<=>).twice.and_return(-1,-1)
    expect((a..'z').===('b')).to be true
  end

  it "uses a continuous inclusion test" do
    expect(('a'..'f').===('aa')).to be true
    expect(('a'..'f').===('babe')).to be true
    expect(('a'..'f').===('baby')).to be true
    expect(('a'..'f').===('ga')).to be false
    expect((-10..-2).===(-2.5)).to be true
  end

  describe "on string elements" do
    it "returns true if other is matched by element.succ" do
      expect(('a'..'c').===('b')).to be true
      expect(('a'...'c').===('b')).to be true
    end

    it "returns true if other is not matched by element.succ" do
      expect(('a'..'c').===('bc')).to be true
      expect(('a'...'c').===('bc')).to be true
    end
  end

  describe "with weird succ" do
    describe "when included end value" do
      before :each do
        @range = RangeSpecs::TenfoldSucc.new(1)..RangeSpecs::TenfoldSucc.new(99)
      end

      it "returns false if other is less than first element" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it "returns true if other is equal as first element" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it "returns true if other is matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it "returns true if other is not matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(2))).to be true
      end

      it "returns true if other is equal as last element but not matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(99))).to be true
      end

      it "returns false if other is greater than last element but matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end

    describe "when excluded end value" do
      before :each do
        @range = RangeSpecs::TenfoldSucc.new(1)...RangeSpecs::TenfoldSucc.new(99)
      end

      it "returns false if other is less than first element" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(0))).to be false
      end

      it "returns true if other is equal as first element" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(1))).to be true
      end

      it "returns true if other is matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(10))).to be true
      end

      it "returns true if other is not matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(2))).to be true
      end

      it "returns false if other is equal as last element but not matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(99))).to be false
      end

      it "returns false if other is greater than last element but matched by element.succ" do
        expect(@range.===(RangeSpecs::TenfoldSucc.new(100))).to be false
      end
    end
  end

  it "returns true on any value if begin and end are both nil" do
    expect(nil..nil).to be === 1
  end
end
