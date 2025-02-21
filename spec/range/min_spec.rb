require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#min" do
  it "returns the minimum value in the range when called with no arguments" do
    expect((1..10).min).to eq(1)
    expect(('f'..'l').min).to eq('f')
  end

  it "returns the minimum value in the Float range when called with no arguments" do
    expect((303.20..908.1111).min).to eq(303.20)
  end

  it "returns nil when the start point is greater than the endpoint" do
    expect((100..10).min).to be_nil
    expect(('z'..'l').min).to be_nil
  end

  it "returns nil when the endpoint equals the start point and the range is exclusive" do
    expect((7...7).min).to be_nil
  end

  it "returns the start point when the endpoint equals the start point and the range is inclusive" do
    expect((7..7).min).to equal(7)
  end

  it "returns nil when the start point is greater than the endpoint in a Float range" do
    expect((3003.20..908.1111).min).to be_nil
  end

  it "returns start point when the range is Time..Time(included end point)" do
    time_start = Time.now
    time_end = Time.now + 1.0
    expect((time_start..time_end).min).to equal(time_start)
  end

  it "returns start point when the range is Time...Time(excluded end point)" do
    time_start = Time.now
    time_end = Time.now + 1.0
    expect((time_start...time_end).min).to equal(time_start)
  end

  it "returns the start point for endless ranges" do
    expect(eval("(1..)").min).to eq(1)
    expect(eval("(1.0...)").min).to eq(1.0)
  end

  it "raises RangeError when called on an beginless range" do
    expect { (..1).min }.to raise_error(RangeError)
  end
end

RSpec.describe "Range#min given a block" do
  it "passes each pair of values in the range to the block" do
    acc = []
    (1..10).min {|a,b| acc << [a,b]; a }
    acc.flatten!
    (1..10).each do |value|
      expect(acc.include?(value)).to be true
    end
  end

  it "passes each pair of elements to the block where the first argument is the current element, and the last is the first element" do
    acc = []
    (1..5).min {|a,b| acc << [a,b]; a }
    expect(acc).to eq([[2, 1], [3, 1], [4, 1], [5, 1]])
  end

  it "calls #> and #< on the return value of the block" do
    obj = double('obj')
    expect(obj).to receive(:>).exactly(2).times
    expect(obj).to receive(:<).exactly(2).times
    (1..3).min {|a,b| obj }
  end

  it "returns the element the block determines to be the minimum" do
    expect((1..3).min {|a,b| -3 }).to eq(3)
  end

  it "returns nil when the start point is greater than the endpoint" do
    expect((100..10).min {|x,y| x <=> y}).to be_nil
    expect(('z'..'l').min {|x,y| x <=> y}).to be_nil
    expect((7...7).min {|x,y| x <=> y}).to be_nil
  end

  it "raises RangeError when called with custom comparison method on an endless range" do
    expect { eval("(1..)").min {|a, b| a} }.to raise_error(RangeError)
  end
end
