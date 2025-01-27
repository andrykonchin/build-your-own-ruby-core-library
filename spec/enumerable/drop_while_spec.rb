require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#drop_while" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "returns an Enumerator if no block given" do
    expect(@enum.drop_while).to be_an_instance_of(Enumerator)
  end

  it "returns no/all elements for {true/false} block" do
    expect(@enum.drop_while{true}).to eq([])
    expect(@enum.drop_while{false}).to eq([3, 2, 1, :go])
  end

  it "accepts returns other than true/false" do
    expect(@enum.drop_while{1}).to eq([])
    expect(@enum.drop_while{nil}).to eq([3, 2, 1, :go])
  end

  it "passes elements to the block until the first false" do
    a = []
    expect(@enum.drop_while{|obj| (a << obj).size < 3}).to eq([1, :go])
    expect(a).to eq([3, 2, 1])
  end

  it "will only go through what's needed" do
    enum = EnumerableSpecs::EachCounter.new(1,2,3,4)
    expect(
      enum.drop_while { |x|
        break 42 if x == 3
        true
      }
    ).to eq(42)
    expect(enum.times_yielded).to eq(3)
  end

  it "doesn't return self when it could" do
    a = [1,2,3]
    expect(a.drop_while{false}).not_to equal(a)
  end

  describe "when #each yields multiple values" do
    it "yields multiple values as array when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.drop_while { |e| yielded << e; true }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it "gathers multiple values as array when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.drop_while { |e| false }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it "yields multiple arguments when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.drop_while { |*args| yielded << args; true }
      expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
    end

    it "gathers multiple values as array when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.drop_while { |*args| false }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4).drop_while.size).to eq(nil)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).drop_while.size).to eq(nil)
        end
      end
    end
  end
end
