require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#first" do
  it "returns the first element" do
    expect(EnumerableSpecs::Numerous.new.first).to eq(2)
    expect(EnumerableSpecs::Empty.new.first).to eq(nil)
  end

  it "returns nil if self is empty" do
    expect(EnumerableSpecs::Empty.new.first).to eq(nil)
  end

  it 'returns a gathered array from yield parameters' do
    expect(EnumerableSpecs::YieldsMulti.new.to_enum.first).to eq([1, 2])
    expect(EnumerableSpecs::YieldsMixed2.new.to_enum.first).to eq(nil)
  end

  it "raises a RangeError when passed a Bignum" do
    enum = EnumerableSpecs::Empty.new
    expect { enum.first(bignum_value) }.to raise_error(RangeError)
  end

  describe "when passed an argument" do
    before :each do
      @values = [4,3,2,1,0,-1]
      @enum = EnumerableSpecs::Numerous.new(*@values)
    end

    it "returns the first count elements if given a count" do
      expect(@enum.first(2)).to eq([4, 3])
      expect(@enum.first(4)).to eq([4, 3, 2, 1]) # See redmine #1686 !
    end

    it "returns an empty array when passed count on an empty array" do
      empty = EnumerableSpecs::Empty.new
      expect(empty.first(0)).to eq([])
      expect(empty.first(1)).to eq([])
      expect(empty.first(2)).to eq([])
    end

    it "returns an empty array when passed count == 0" do
      expect(@enum.first(0)).to eq([])
    end

    it "returns an array containing the first element when passed count == 1" do
      expect(@enum.first(1)).to eq([4])
    end

    it "raises an ArgumentError when count is negative" do
      expect { @enum.first(-1) }.to raise_error(ArgumentError)
    end

    it "returns the entire array when count > length" do
      expect(@enum.first(100)).to eq(@values)
      expect(@enum.first(8)).to eq(@values)  # See redmine #1686 !
    end

    it "tries to convert the passed argument to an Integer using #to_int" do
      obj = double('to_int')
      expect(obj).to receive(:to_int).at_most(:twice).and_return(3) # called twice, no apparent reason. See redmine #1554
      expect(@enum.first(obj)).to eq([4, 3, 2])
    end

    it "raises a TypeError if the passed argument is not numeric" do
      expect { @enum.first(nil) }.to raise_error(TypeError)
      expect { @enum.first("a") }.to raise_error(TypeError)

      obj = double("nonnumeric")
      expect { @enum.first(obj) }.to raise_error(TypeError)
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.first(1)).to eq([[1, 2]])
    end

    it "consumes only what is needed" do
      thrower = EnumerableSpecs::ThrowingEach.new
      expect(thrower.first(0)).to eq([])
      counter = EnumerableSpecs::EachCounter.new(1,2,3,4)
      expect(counter.first(2)).to eq([1,2])
      expect(counter.times_called).to eq(1)
      expect(counter.times_yielded).to eq(2)
    end
  end
end
