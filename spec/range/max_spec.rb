require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#max" do
  it "returns the maximum value in the range when called with no arguments" do
    expect((1..10).max).to eq(10)
    expect((1...10).max).to eq(9)
    expect((0...2**64).max).to eq(18446744073709551615)
    expect(('f'..'l').max).to eq('l')
    expect(('a'...'f').max).to eq('e')
  end

  it "returns the maximum value in the Float range when called with no arguments" do
    expect((303.20..908.1111).max).to eq(908.1111)
  end

  it "raises TypeError when called on an exclusive range and a non Integer value" do
    expect { (303.20...908.1111).max }.to raise_error(TypeError)
  end

  it "returns nil when the endpoint is less than the start point" do
    expect((100..10).max).to be_nil
    expect(('z'..'l').max).to be_nil
  end

  it "returns nil when the endpoint equals the start point and the range is exclusive" do
    expect((5...5).max).to be_nil
  end

  it "returns the endpoint when the endpoint equals the start point and the range is inclusive" do
    expect((5..5).max).to equal(5)
  end

  it "returns nil when the endpoint is less than the start point in a Float range" do
    expect((3003.20..908.1111).max).to be_nil
  end

  it "returns end point when the range is Time..Time(included end point)" do
    time_start = Time.now
    time_end = Time.now + 1.0
    expect((time_start..time_end).max).to equal(time_end)
  end

  it "raises TypeError when called on a Time...Time(excluded end point)" do
    time_start = Time.now
    time_end = Time.now + 1.0
    expect { (time_start...time_end).max  }.to raise_error(TypeError)
  end

  it "raises RangeError when called on an endless range" do
    expect { eval("(1..)").max }.to raise_error(RangeError)
  end

  it "returns the end point for beginless ranges" do
    expect((..1).max).to eq(1)
    expect((..1.0).max).to eq(1.0)
  end

  it "raises for an exclusive beginless range" do
    expect {
      (...1).max
    }.to raise_error(TypeError, 'cannot exclude end value with non Integer begin value')
  end
end

RSpec.describe "Range#max given a block" do
  it "passes each pair of values in the range to the block" do
    acc = []
    (1..10).max {|a,b| acc << [a,b]; a }
    acc.flatten!
    (1..10).each do |value|
      expect(acc.include?(value)).to be true
    end
  end

  it "passes each pair of elements to the block in reversed order" do
    acc = []
    (1..5).max {|a,b| acc << [a,b]; a }
    expect(acc).to eq([[2,1],[3,2], [4,3], [5, 4]])
  end

  it "calls #> and #< on the return value of the block" do
    obj = double('obj')
    expect(obj).to receive(:>).exactly(2).times
    expect(obj).to receive(:<).exactly(2).times
    (1..3).max {|a,b| obj }
  end

  it "returns the element the block determines to be the maximum" do
    expect((1..3).max {|a,b| -3 }).to eq(1)
  end

  it "returns nil when the endpoint is less than the start point" do
    expect((100..10).max {|x,y| x <=> y}).to be_nil
    expect(('z'..'l').max {|x,y| x <=> y}).to be_nil
    expect((5...5).max {|x,y| x <=> y}).to be_nil
  end

  it "raises RangeError when called with custom comparison method on an beginless range" do
    expect { (..1).max {|a, b| a} }.to raise_error(RangeError)
  end
end
