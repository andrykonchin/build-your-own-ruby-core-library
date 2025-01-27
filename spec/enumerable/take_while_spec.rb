require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#take_while" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "returns an Enumerator if no block given" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.take_while).to be_an_instance_of(Enumerator)
    expect(enum.take_while.to_a).to eq([1])
    expect(enum.take_while.each { |i| i < 3 }).to eq([1, 2])
  end

  it "passes elements to the block until the first false" do
    a = []
    expect(@enum.take_while{|obj| (a << obj).size < 3}).to eq([3, 2])
    expect(a).to eq([3, 2, 1])
  end

  it "returns no/all elements for {true/false} block" do
    expect(@enum.take_while{true}).to eq(@enum.to_a)
    expect(@enum.take_while{false}).to eq([])
  end

  it "accepts returns other than true/false" do
    expect(@enum.take_while{1}).to eq(@enum.to_a)
    expect(@enum.take_while{nil}).to eq([])
  end

  it "will only go through what is needed" do
    enum = EnumerableSpecs::EachCounter.new(4, 3, 2, 1)
    expect(enum.take_while { |x|
      break 42 if x == 3
      true
    }).to eq(42)
    expect(enum.times_yielded).to eq(2)
  end

  it "does not return self when it could" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.take_while{true}).not_to equal(enum)
  end

  describe "when #each yields multiple values" do
    it "yields multiple arguments when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.take_while { |e| yielded << e; true }
      expect(yielded).to eq([1, 3, 6])
    end

    it "yields multiple arguments when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.take_while { |*args| yielded << args; true }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4).take_while
          expect(enum.size).to eq(nil)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4).take_while
          expect(enum.size).to eq(nil)
        end
      end
    end
  end
end
