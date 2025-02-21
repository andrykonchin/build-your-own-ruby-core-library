require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#first" do
  it "returns the first element of self" do
    expect((-1..1).first).to eq(-1)
    expect((0..1).first).to eq(0)
    expect((0xffff...0xfffff).first).to eq(65535)
    expect(('Q'..'T').first).to eq('Q')
    expect(('Q'...'T').first).to eq('Q')
    expect((0.5..2.4).first).to eq(0.5)
  end

  it "returns the specified number of elements from the beginning" do
    expect((0..2).first(2)).to eq([0, 1])
  end

  it "returns an empty array for an empty Range" do
    expect((0...0).first(2)).to eq([])
  end

  it "returns an empty array when passed zero" do
    expect((0..2).first(0)).to eq([])
  end

  it "returns all elements in the range when count exceeds the number of elements" do
    expect((0..2).first(4)).to eq([0, 1, 2])
  end

  it "raises an ArgumentError when count is negative" do
    expect { (0..2).first(-1) }.to raise_error(ArgumentError)
  end

  it "calls #to_int to convert the argument" do
    obj = mock_int(2)
    expect((3..7).first(obj)).to eq([3, 4])
  end

  it "raises a TypeError if #to_int does not return an Integer" do
    obj = double("to_int")
    expect(obj).to receive(:to_int).and_return("1")
    expect { (2..3).first(obj) }.to raise_error(TypeError)
  end

  it "truncates the value when passed a Float" do
    expect((2..9).first(2.8)).to eq([2, 3])
  end

  it "raises a TypeError when passed nil" do
    expect { (2..3).first(nil) }.to raise_error(TypeError)
  end

  it "raises a TypeError when passed a String" do
    expect { (2..3).first("1") }.to raise_error(TypeError)
  end

  it "raises a RangeError when called on an beginless range" do
    expect { (..1).first }.to raise_error(RangeError)
  end
end
