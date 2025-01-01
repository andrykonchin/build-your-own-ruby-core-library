require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#take" do
  it "requires an argument" do
    expect{ EnumerableSpecs::Numerous.new.take}.to raise_error(ArgumentError)
  end

  describe "when passed an argument" do
    before :each do
      @values = [4,3,2,1,0,-1]
      @enum = EnumerableSpecs::Numerous.new(*@values)
    end

    it "returns the first count elements if given a count" do
      expect(@enum.take(2)).to eq([4, 3])
      expect(@enum.take(4)).to eq([4, 3, 2, 1]) # See redmine #1686 !
    end

    it "returns an empty array when passed count on an empty array" do
      empty = EnumerableSpecs::Empty.new
      expect(empty.take(0)).to eq([])
      expect(empty.take(1)).to eq([])
      expect(empty.take(2)).to eq([])
    end

    it "returns an empty array when passed count == 0" do
      expect(@enum.take(0)).to eq([])
    end

    it "returns an array containing the first element when passed count == 1" do
      expect(@enum.take(1)).to eq([4])
    end

    it "raises an ArgumentError when count is negative" do
      expect { @enum.take(-1) }.to raise_error(ArgumentError)
    end

    it "returns the entire array when count > length" do
      expect(@enum.take(100)).to eq(@values)
      expect(@enum.take(8)).to eq(@values)  # See redmine #1686 !
    end

    it "tries to convert the passed argument to an Integer using #to_int" do
      obj = double('to_int')
      expect(obj).to receive(:to_int).at_most(:twice).and_return(3) # called twice, no apparent reason. See redmine #1554
      expect(@enum.take(obj)).to eq([4, 3, 2])
    end

    it "raises a TypeError if the passed argument is not numeric" do
      expect { @enum.take(nil) }.to raise_error(TypeError)
      expect { @enum.take("a") }.to raise_error(TypeError)

      obj = double("nonnumeric")
      expect { @enum.take(obj) }.to raise_error(TypeError)
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.take(1)).to eq([[1, 2]])
    end

    it "consumes only what is needed" do
      thrower = EnumerableSpecs::ThrowingEach.new
      expect(thrower.take(0)).to eq([])
      counter = EnumerableSpecs::EachCounter.new(1,2,3,4)
      expect(counter.take(2)).to eq([1,2])
      expect(counter.times_called).to eq(1)
      expect(counter.times_yielded).to eq(2)
    end
  end
end
