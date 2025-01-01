require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#reject" do
  it "returns an array of the elements for which block is false" do
    expect(EnumerableSpecs::Numerous.new.reject { |i| i > 3 }).to eq([2, 3, 1])
    entries = (1..10).to_a
    numerous = EnumerableSpecs::Numerous.new(*entries)
    expect(numerous.reject {|i| i % 2 == 0 }).to eq([1,3,5,7,9])
    expect(numerous.reject {|i| true }).to eq([])
    expect(numerous.reject {|i| false }).to eq(entries)
  end

  it "returns an Enumerator if called without a block" do
    expect(EnumerableSpecs::Numerous.new.reject).to be_an_instance_of(Enumerator)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.reject {|e| e == [3, 4, 5] }).to eq([[1, 2], [6, 7, 8, 9]])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.reject.size).to eq(@object.size)
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
          expect(@object.reject.size).to eq(nil)
        end
      end
    end
  end
end
