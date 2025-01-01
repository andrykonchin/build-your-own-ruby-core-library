require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#minmax_by" do
  it "returns an enumerator if no block" do
    expect(EnumerableSpecs::Numerous.new(42).minmax_by).to be_an_instance_of(Enumerator)
  end

  it "returns nil if #each yields no objects" do
    expect(EnumerableSpecs::Empty.new.minmax_by {|o| o.nonesuch }).to eq([nil, nil])
  end

  it "returns the object for whom the value returned by block is the largest" do
    expect(EnumerableSpecs::Numerous.new(*%w[1 2 3]).minmax_by {|obj| obj.to_i }).to eq(['1', '3'])
    expect(EnumerableSpecs::Numerous.new(*%w[three five]).minmax_by {|obj| obj.length }).to eq(['five', 'three'])
  end

  it "returns the object that appears first in #each in case of a tie" do
    a, b, c, d = '1', '1', '2', '2'
    mm = EnumerableSpecs::Numerous.new(a, b, c, d).minmax_by {|obj| obj.to_i }
    expect(mm[0]).to equal(a)
    expect(mm[1]).to equal(c)
  end

  it "uses min/max.<=>(current) to determine order" do
    a, b, c = (1..3).map{|n| EnumerableSpecs::ReverseComparable.new(n)}

    # Just using self here to avoid additional complexity
    expect(EnumerableSpecs::Numerous.new(a, b, c).minmax_by {|obj| obj }).to eq([c, a])
  end

  it "is able to return the maximum for enums that contain nils" do
    enum = EnumerableSpecs::Numerous.new(nil, nil, true)
    expect(enum.minmax_by {|o| o.nil? ? 0 : 1 }).to eq([nil, true])
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.minmax_by {|e| e.size}).to eq([[1, 2], [6, 7, 8, 9]])
  end

  describe "Enumerable with size" do
    before do
      @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          expect(@object.minmax_by.size).to eq(@object.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    before do
      @object = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(@object.minmax_by.size).to eq(nil)
        end
      end
    end
  end
end
