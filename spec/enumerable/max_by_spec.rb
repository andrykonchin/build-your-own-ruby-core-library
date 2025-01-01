require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#max_by" do
  it "returns an enumerator if no block" do
    expect(EnumerableSpecs::Numerous.new(42).max_by).to be_an_instance_of(Enumerator)
  end

  it "returns nil if #each yields no objects" do
    expect(EnumerableSpecs::Empty.new.max_by {|o| o.nonesuch }).to eq(nil)
  end

  it "returns the object for whom the value returned by block is the largest" do
    expect(EnumerableSpecs::Numerous.new(*%w[1 2 3]).max_by {|obj| obj.to_i }).to eq('3')
    expect(EnumerableSpecs::Numerous.new(*%w[three five]).max_by {|obj| obj.length }).to eq('three')
  end

  it "returns the object that appears first in #each in case of a tie" do
    a, b, c = '1', '2', '2'
    expect(EnumerableSpecs::Numerous.new(a, b, c).max_by {|obj| obj.to_i }).to equal(b)
  end

  it "uses max.<=>(current) to determine order" do
    a, b, c = (1..3).map{|n| EnumerableSpecs::ReverseComparable.new(n)}

    # Just using self here to avoid additional complexity
    expect(EnumerableSpecs::Numerous.new(a, b, c).max_by {|obj| obj }).to eq(a)
  end

  it "is able to return the maximum for enums that contain nils" do
    enum = EnumerableSpecs::Numerous.new(nil, nil, true)
    expect(enum.max_by {|o| o.nil? ? 0 : 1 }).to eq(true)
    expect(enum.max_by {|o| o.nil? ? 1 : 0 }).to eq(nil)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.max_by {|e| e.size}).to eq([6, 7, 8, 9])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.max_by.size).to eq(@object.size)
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
          expect(@object.max_by.size).to eq(nil)
        end
      end
    end
  end

  context "when called with an argument n" do
    before :each do
      @enum = EnumerableSpecs::Numerous.new(101, 55, 1, 20, 33, 500, 60)
    end

    context "without a block" do
      it "returns an enumerator" do
        expect(@enum.max_by(2)).to be_an_instance_of(Enumerator)
      end
    end

    context "with a block" do
      it "returns an array containing the maximum n elements based on the block's value" do
        result = @enum.max_by(3) { |i| i.to_s }
        expect(result).to eq([60, 55, 500])
      end

      context "on a enumerable of length x where x < n" do
        it "returns an array containing the maximum n elements of length n" do
          result = @enum.max_by(500) { |i| i.to_s }
          expect(result.length).to eq(7)
        end
      end

      context "when n is negative" do
        it "raises an ArgumentError" do
          expect { @enum.max_by(-1) { |i| i.to_s } }.to raise_error(ArgumentError)
        end
      end
    end

    context "when n is nil" do
      it "returns the maximum element" do
        expect(@enum.max_by(nil) { |i| i.to_s }).to eq(60)
      end
    end
  end
end
