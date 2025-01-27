require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#reject" do
  it "returns an array of the elements for which block is false" do
    expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).reject { |i| i < 3 }).to eq([3, 4])

    entries = (1..10).to_a
    numerous = EnumerableSpecs::Numerous.new(*entries)
    expect(numerous.reject {|i| i % 2 == 0 }).to eq([1,3,5,7,9])
    expect(numerous.reject {|i| true }).to eq([])
    expect(numerous.reject {|i| false }).to eq(entries)
  end

  it "returns an Enumerator if called without a block" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.reject).to be_an_instance_of(Enumerator)
    expect(enum.reject.to_a).to eq([1, 2, 3, 4])
    expect(enum.reject.each { |i| i < 3 }).to eq([3, 4])
  end

  describe "when #each yields multiple values" do
    it "yields multiple values as array when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.reject {|e| yielded << e }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it "gathers whole arrays as elements when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.reject {|e| false }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it "yields multiple values as array when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.reject {|*args| yielded << args }
      expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
    end

    it "gathers multiple values as array when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.reject {|*args| false }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.reject.size).to eq(enum.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).reject.size).to eq(nil)
        end
      end
    end
  end
end
