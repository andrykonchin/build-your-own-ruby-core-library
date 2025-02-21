require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range.new" do
  it "constructs a range using the given start and end" do
    range = Range.new('a', 'c')
    expect(range).to eq('a'..'c')

    expect(range.first).to eq('a')
    expect(range.last).to eq('c')
  end

  it "includes the end object when the third parameter is omitted or false" do
    expect(Range.new('a', 'c').to_a).to eq(['a', 'b', 'c'])
    expect(Range.new(1, 3).to_a).to eq([1, 2, 3])

    expect(Range.new('a', 'c', false).to_a).to eq(['a', 'b', 'c'])
    expect(Range.new(1, 3, false).to_a).to eq([1, 2, 3])

    expect(Range.new('a', 'c', true).to_a).to eq(['a', 'b'])
    expect(Range.new(1, 3, 1).to_a).to eq([1, 2])

    expect(Range.new(1, 3, double('[1,2]')).to_a).to eq([1, 2])
    expect(Range.new(1, 3, :test).to_a).to eq([1, 2])
  end

  it "raises an ArgumentError when the given start and end can't be compared by using #<=>" do
    expect { Range.new(1, double('x'))         }.to raise_error(ArgumentError)
    expect { Range.new(double('x'), double('y')) }.to raise_error(ArgumentError)

    b = double('x')
    expect(a = double('nil')).to receive(:<=>).with(b).and_return(nil)
    expect { Range.new(a, b) }.to raise_error(ArgumentError)
  end

  it "does not rescue exception raised in #<=> when compares the given start and end" do
    b = double('a')
    a = double('b')
    expect(a).to receive(:<=>).with(b).and_raise(RangeSpecs::ComparisonError)

    expect { Range.new(a, b) }.to raise_error(RangeSpecs::ComparisonError)
  end

  describe "beginless/endless range" do
    it "allows beginless left boundary" do
      range = Range.new(nil, 1)
      expect(range.begin).to eq(nil)
    end

    it "distinguishes ranges with included and excluded right boundary" do
      range_exclude = Range.new(nil, 1, true)
      range_include = Range.new(nil, 1, false)

      expect(range_exclude).not_to eq(range_include)
    end

    it "allows endless right boundary" do
      range = Range.new(1, nil)
      expect(range.end).to eq(nil)
    end

    it "distinguishes ranges with included and excluded right boundary" do
      range_exclude = Range.new(1, nil, true)
      range_include = Range.new(1, nil, false)

      expect(range_exclude).not_to eq(range_include)
    end

    it "creates a frozen range if the class is Range.class" do
      expect(Range.new(1, 2).frozen?).to be true
    end

    it "does not create a frozen range if the class is not Range.class" do
      expect(Class.new(Range).new(1, 2).frozen?).to be false
    end
  end
end
