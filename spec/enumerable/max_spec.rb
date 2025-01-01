require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#max" do
  before :each do
    @e_strs = EnumerableSpecs::EachDefiner.new("333", "22", "666666", "1", "55555", "1010101010")
    @e_ints = EnumerableSpecs::EachDefiner.new( 333,   22,   666666,   55555, 1010101010)
  end

  it "returns the maximum element" do
    expect(EnumerableSpecs::Numerous.new.max).to eq(6)
  end

  it "returns the maximum element (basics cases)" do
    expect(EnumerableSpecs::EachDefiner.new(55).max).to eq(55)

    expect(EnumerableSpecs::EachDefiner.new(11,99).max).to eq(99)
    expect(EnumerableSpecs::EachDefiner.new(99,11).max).to eq(99)
    expect(EnumerableSpecs::EachDefiner.new(2, 33, 4, 11).max).to eq(33)

    expect(EnumerableSpecs::EachDefiner.new(1,2,3,4,5).max).to eq(5)
    expect(EnumerableSpecs::EachDefiner.new(5,4,3,2,1).max).to eq(5)
    expect(EnumerableSpecs::EachDefiner.new(1,4,3,5,2).max).to eq(5)
    expect(EnumerableSpecs::EachDefiner.new(5,5,5,5,5).max).to eq(5)

    expect(EnumerableSpecs::EachDefiner.new("aa","tt").max).to eq("tt")
    expect(EnumerableSpecs::EachDefiner.new("tt","aa").max).to eq("tt")
    expect(EnumerableSpecs::EachDefiner.new("2","33","4","11").max).to eq("4")

    expect(@e_strs.max).to eq("666666")
    expect(@e_ints.max).to eq(1010101010)
  end

  it "returns nil for an empty Enumerable" do
    expect(EnumerableSpecs::EachDefiner.new.max).to eq(nil)
  end

  it "raises a NoMethodError for elements without #<=>" do
    expect do
      EnumerableSpecs::EachDefiner.new(BasicObject.new, BasicObject.new).max
    end.to raise_error(NoMethodError)
  end

  it "raises an ArgumentError for incomparable elements" do
    expect do
      EnumerableSpecs::EachDefiner.new(11,"22").max
    end.to raise_error(ArgumentError)
    expect do
      EnumerableSpecs::EachDefiner.new(11,12,22,33).max{|a, b| nil}
    end.to raise_error(ArgumentError)
  end

  context "when passed a block" do
    it "returns the maximum element" do
      expect(EnumerableSpecs::EachDefiner.new("2","33","4","11").max {|a,b| a <=> b }).to eq("4")
      expect(EnumerableSpecs::EachDefiner.new( 2 , 33 , 4 , 11 ).max {|a,b| a <=> b }).to eq(33)

      expect(EnumerableSpecs::EachDefiner.new("2","33","4","11").max {|a,b| b <=> a }).to eq("11")
      expect(EnumerableSpecs::EachDefiner.new( 2 , 33 , 4 , 11 ).max {|a,b| b <=> a }).to eq(2)

      expect(@e_strs.max {|a,b| a.length <=> b.length }).to eq("1010101010")

      expect(@e_strs.max {|a,b| a <=> b }).to eq("666666")
      expect(@e_strs.max {|a,b| a.to_i <=> b.to_i }).to eq("1010101010")

      expect(@e_ints.max {|a,b| a <=> b }).to eq(1010101010)
      expect(@e_ints.max {|a,b| a.to_s <=> b.to_s }).to eq(666666)
    end
  end

  it "returns the maximum for enumerables that contain nils" do
    arr = EnumerableSpecs::Numerous.new(nil, nil, true)
    expect(arr.max { |a, b|
      x = a.nil? ? 1 : a ? 0 : -1
      y = b.nil? ? 1 : b ? 0 : -1
      x <=> y
    }).to eq(nil)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.max).to eq([6, 7, 8, 9])
  end

  context "when called with an argument n" do
    context "without a block" do
      it "returns an array containing the maximum n elements" do
        result = @e_ints.max(2)
        expect(result).to eq([1010101010, 666666])
      end
    end

    context "with a block" do
      it "returns an array containing the maximum n elements" do
        result = @e_ints.max(2) { |a, b| a * 2 <=> b * 2 }
        expect(result).to eq([1010101010, 666666])
      end
    end

    context "on a enumerable of length x where x < n" do
      it "returns an array containing the maximum n elements of length x" do
        result = @e_ints.max(500)
        expect(result.length).to eq(5)
      end
    end

    context "that is negative" do
      it "raises an ArgumentError" do
        expect { @e_ints.max(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  context "that is nil" do
    it "returns the maximum element" do
      expect(@e_ints.max(nil)).to eq(1010101010)
    end
  end
end
