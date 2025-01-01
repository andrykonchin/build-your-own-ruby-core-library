require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#sort_by" do
  it "returns an array of elements ordered by the result of block" do
    a = EnumerableSpecs::Numerous.new("once", "upon", "a", "time")
    expect(a.sort_by { |i| i[0] }).to eq(["a", "once", "time", "upon"])
  end

  it "sorts the object by the given attribute" do
    a = EnumerableSpecs::SortByDummy.new("fooo")
    b = EnumerableSpecs::SortByDummy.new("bar")

    ar = [a, b].sort_by { |d| d.s }
    expect(ar).to eq([b, a])
  end

  it "returns an Enumerator when a block is not supplied" do
    a = EnumerableSpecs::Numerous.new("a","b")
    expect(a.sort_by).to be_an_instance_of(Enumerator)
    expect(a.to_a).to eq(["a", "b"])
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.sort_by {|e| e.size}).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
  end

  it "returns an array of elements when a block is supplied and #map returns an enumerable" do
    b = EnumerableSpecs::MapReturnsEnumerable.new
    expect(b.sort_by{ |x| -x }).to eq([3, 2, 1])
  end

  it "calls #each to iterate over the elements to be sorted" do
    b = EnumerableSpecs::Numerous.new( 1, 2, 3 )
    expect(b).to receive(:each).once.and_yield(1).and_yield(2).and_yield(3)
    expect(b).not_to receive :map
    expect(b.sort_by { |x| -x }).to eq([3, 2, 1])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.sort_by.size).to eq(@object.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        end

        it "size returns nil" do
          expect(@object.sort_by.size).to eq(nil)
        end
      end
    end
  end
end
