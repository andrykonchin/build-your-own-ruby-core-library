require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#last" do
  it "end returns the last element of self" do
    expect((-1..1).last).to eq(1)
    expect((0..1).last).to eq(1)
    expect(("A".."Q").last).to eq("Q")
    expect(("A"..."Q").last).to eq("Q")
    expect((0xffff...0xfffff).last).to eq(1048575)
    expect((0.5..2.4).last).to eq(2.4)
  end

  it "returns the specified number of elements from the end" do
    expect((1..5).last(3)).to eq([3, 4, 5])
  end

  it "returns the specified number if elements for single element inclusive range" do
    expect((1..1).last(1)).to eq([1])
  end

  it "returns an empty array for an empty Range" do
    expect((0...0).last(2)).to eq([])
  end

  it "returns an empty array when passed zero" do
    expect((0..2).last(0)).to eq([])
  end

  it "returns all elements in the range when count exceeds the number of elements" do
    expect((2..4).last(5)).to eq([2, 3, 4])
  end

  it "raises an ArgumentError when count is negative" do
    expect { (0..2).last(-1) }.to raise_error(ArgumentError)
  end

  it "calls #to_int to convert the argument" do
    obj = mock_int(2)
    expect((3..7).last(obj)).to eq([6, 7])
  end

  it "raises a TypeError if #to_int does not return an Integer" do
    obj = double("to_int")
    expect(obj).to receive(:to_int).and_return("1")
    expect { (2..3).last(obj) }.to raise_error(TypeError)
  end

  it "truncates the value when passed a Float" do
    expect((2..9).last(2.8)).to eq([8, 9])
  end

  it "raises a TypeError when passed nil" do
    expect { (2..3).last(nil) }.to raise_error(TypeError)
  end

  it "raises a TypeError when passed a String" do
    expect { (2..3).last("1") }.to raise_error(TypeError)
  end

  it "raises a RangeError when called on an endless range" do
    expect { eval("(1..)").last }.to raise_error(RangeError)
  end
end
