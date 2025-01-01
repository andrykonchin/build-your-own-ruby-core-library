require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#min" do
  before :each do
    @e_strs = EnumerableSpecs::EachDefiner.new("333", "22", "666666", "1", "55555", "1010101010")
    @e_ints = EnumerableSpecs::EachDefiner.new( 333,   22,   666666,   55555, 1010101010)
  end

  it "min should return the minimum element" do
    expect(EnumerableSpecs::Numerous.new.min).to eq(1)
  end

  it "returns the minimum (basic cases)" do
    expect(EnumerableSpecs::EachDefiner.new(55).min).to eq(55)

    expect(EnumerableSpecs::EachDefiner.new(11,99).min).to eq(11)
    expect(EnumerableSpecs::EachDefiner.new(99,11).min).to eq(11)
    expect(EnumerableSpecs::EachDefiner.new(2, 33, 4, 11).min).to eq(2)

    expect(EnumerableSpecs::EachDefiner.new(1,2,3,4,5).min).to eq(1)
    expect(EnumerableSpecs::EachDefiner.new(5,4,3,2,1).min).to eq(1)
    expect(EnumerableSpecs::EachDefiner.new(4,1,3,5,2).min).to eq(1)
    expect(EnumerableSpecs::EachDefiner.new(5,5,5,5,5).min).to eq(5)

    expect(EnumerableSpecs::EachDefiner.new("aa","tt").min).to eq("aa")
    expect(EnumerableSpecs::EachDefiner.new("tt","aa").min).to eq("aa")
    expect(EnumerableSpecs::EachDefiner.new("2","33","4","11").min).to eq("11")

    expect(@e_strs.min).to eq("1")
    expect(@e_ints.min).to eq(22)
  end

  it "returns nil for an empty Enumerable" do
    expect(EnumerableSpecs::EachDefiner.new.min).to be_nil
  end

  it "raises a NoMethodError for elements without #<=>" do
    expect do
      EnumerableSpecs::EachDefiner.new(BasicObject.new, BasicObject.new).min
    end.to raise_error(NoMethodError)
  end

  it "raises an ArgumentError for incomparable elements" do
    expect do
      EnumerableSpecs::EachDefiner.new(11,"22").min
    end.to raise_error(ArgumentError)
    expect do
      EnumerableSpecs::EachDefiner.new(11,12,22,33).min{|a, b| nil}
    end.to raise_error(ArgumentError)
  end

  it "returns the minimum when using a block rule" do
    expect(EnumerableSpecs::EachDefiner.new("2","33","4","11").min {|a,b| a <=> b }).to eq("11")
    expect(EnumerableSpecs::EachDefiner.new( 2 , 33 , 4 , 11 ).min {|a,b| a <=> b }).to eq(2)

    expect(EnumerableSpecs::EachDefiner.new("2","33","4","11").min {|a,b| b <=> a }).to eq("4")
    expect(EnumerableSpecs::EachDefiner.new( 2 , 33 , 4 , 11 ).min {|a,b| b <=> a }).to eq(33)

    expect(EnumerableSpecs::EachDefiner.new( 1, 2, 3, 4 ).min {|a,b| 15 }).to eq(1)

    expect(EnumerableSpecs::EachDefiner.new(11,12,22,33).min{|a, b| 2 }).to eq(11)
    @i = -2
    expect(EnumerableSpecs::EachDefiner.new(11,12,22,33).min{|a, b| @i += 1 }).to eq(12)

    expect(@e_strs.min {|a,b| a.length <=> b.length }).to eq("1")

    expect(@e_strs.min {|a,b| a <=> b }).to eq("1")
    expect(@e_strs.min {|a,b| a.to_i <=> b.to_i }).to eq("1")

    expect(@e_ints.min {|a,b| a <=> b }).to eq(22)
    expect(@e_ints.min {|a,b| a.to_s <=> b.to_s }).to eq(1010101010)
  end

  it "returns the minimum for enumerables that contain nils" do
    arr = EnumerableSpecs::Numerous.new(nil, nil, true)
    expect(arr.min { |a, b|
      x = a.nil? ? -1 : a ? 0 : 1
      y = b.nil? ? -1 : b ? 0 : 1
      x <=> y
    }).to eq(nil)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.min).to eq([1, 2])
  end

  context "when called with an argument n" do
    context "without a block" do
      it "returns an array containing the minimum n elements" do
        result = @e_ints.min(2)
        expect(result).to eq([22, 333])
      end
    end

    context "with a block" do
      it "returns an array containing the minimum n elements" do
        result = @e_ints.min(2) { |a, b| a * 2 <=> b * 2 }
        expect(result).to eq([22, 333])
      end
    end

    context "on a enumerable of length x where x < n" do
      it "returns an array containing the minimum n elements of length x" do
        result = @e_ints.min(500)
        expect(result.length).to eq(5)
      end
    end

    context "that is negative" do
      it "raises an ArgumentError" do
        expect { @e_ints.min(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  context "that is nil" do
    it "returns the minimum element" do
      expect(@e_ints.min(nil)).to eq(22)
    end
  end
end
