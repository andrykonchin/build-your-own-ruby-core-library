require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#partition" do
  it "returns two arrays, the first containing elements for which the block is true, the second containing the rest" do
    expect(EnumerableSpecs::Numerous.new.partition { |i| i % 2 == 0 }).to eq([[2, 6, 4], [5, 3, 1]])
  end

  it "returns an Enumerator if called without a block" do
    expect(EnumerableSpecs::Numerous.new.partition).to be_an_instance_of(Enumerator)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.partition {|e| e == [3, 4, 5] }).to eq([[[3, 4, 5]], [[1, 2], [6, 7, 8, 9]]])
  end

  describe "Enumerable with size" do
    before do
      @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          expect(@object.partition.size).to eq(@object.size)
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
          expect(@object.partition.size).to eq(nil)
        end
      end
    end
  end
end
