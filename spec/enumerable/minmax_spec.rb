require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#minmax" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(6, 4, 5, 10, 8)
    @empty_enum = EnumerableSpecs::Empty.new
    @incomparable_enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new)
    @incompatible_enum = EnumerableSpecs::Numerous.new(11,"22")
    @strs = EnumerableSpecs::Numerous.new("333", "2", "60", "55555", "1010", "111")
  end

  it "returns the minimum element" do
    expect(@enum.minmax).to eq([4, 10])
    expect(@strs.minmax).to eq(["1010", "60"])
  end

  it "returns the minimum when using a block rule" do
    expect(@enum.minmax {|a,b| b <=> a }).to eq([10, 4])
    expect(@strs.minmax {|a,b| a.length <=> b.length }).to eq(["2", "55555"])
  end

  it "returns [nil, nil] for an empty Enumerable" do
    expect(@empty_enum.minmax).to eq([nil, nil])
  end

  it "raises a NoMethodError for elements without #<=>" do
    expect { @incomparable_enum.minmax }.to raise_error(NoMethodError)
  end

  it "raises an ArgumentError when elements are incompatible" do
    expect { @incompatible_enum.minmax }.to raise_error(ArgumentError)
    expect { @enum.minmax{ |a, b| nil } }.to raise_error(ArgumentError)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.minmax).to eq([[1, 2], [6, 7, 8, 9]])
  end
end
