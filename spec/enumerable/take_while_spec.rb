require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#take_while" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "returns an Enumerator if no block given" do
    expect(@enum.take_while).to be_an_instance_of(Enumerator)
  end

  it "returns no/all elements for {true/false} block" do
    expect(@enum.take_while{true}).to eq(@enum.to_a)
    expect(@enum.take_while{false}).to eq([])
  end

  it "accepts returns other than true/false" do
    expect(@enum.take_while{1}).to eq(@enum.to_a)
    expect(@enum.take_while{nil}).to eq([])
  end

  it "passes elements to the block until the first false" do
    a = []
    expect(@enum.take_while{|obj| (a << obj).size < 3}).to eq([3, 2])
    expect(a).to eq([3, 2, 1])
  end

  it "will only go through what's needed" do
    enum = EnumerableSpecs::EachCounter.new(4, 3, 2, 1, :stop)
    expect(enum.take_while { |x|
      break 42 if x == 3
      true
    }).to eq(42)
    expect(enum.times_yielded).to eq(2)
  end

  it "doesn't return self when it could" do
    a = [1,2,3]
    expect(a.take_while{true}).not_to equal(a)
  end

  it "calls the block with initial args when yielded with multiple arguments" do
    yields = []
    EnumerableSpecs::YieldsMixed.new.take_while{ |v| yields << v }
    expect(yields).to eq([1, [2], 3, 5, [8, 9], nil, []])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before :all do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns nil" do
          expect(@object.take_while.size).to eq(nil)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before :all do
          @object = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        end
        it "size returns nil" do
          expect(@object.take_while.size).to eq(nil)
        end
      end
    end
  end
end
