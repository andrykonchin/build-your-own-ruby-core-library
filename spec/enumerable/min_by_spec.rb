require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#min_by" do
  it "returns an enumerator if no block" do
    expect(EnumerableSpecs::Numerous.new(42).min_by).to be_an_instance_of(Enumerator)
  end

  it "returns nil if #each yields no objects" do
    expect(EnumerableSpecs::Empty.new.min_by {|o| o.nonesuch }).to eq(nil)
  end

  it "returns the object for whom the value returned by block is the smallest" do
    expect(EnumerableSpecs::Numerous.new(*%w[3 2 1]).min_by {|obj| obj.to_i }).to eq('1')
    expect(EnumerableSpecs::Numerous.new(*%w[five three]).min_by {|obj| obj.length }).to eq('five')
  end

  it "returns the object that appears first in #each in case of a tie" do
    a, b, c = '2', '1', '1'
    expect(EnumerableSpecs::Numerous.new(a, b, c).min_by {|obj| obj.to_i }).to equal(b)
  end

  it "uses min.<=>(current) to determine order" do
    a, b, c = (1..3).map{|n| EnumerableSpecs::ReverseComparable.new(n)}

    # Just using self here to avoid additional complexity
    expect(EnumerableSpecs::Numerous.new(a, b, c).min_by {|obj| obj }).to eq(c)
  end

  it "is able to return the minimum for enums that contain nils" do
    enum = EnumerableSpecs::Numerous.new(nil, nil, true)
    expect(enum.min_by {|o| o.nil? ? 0 : 1 }).to eq(nil)
    expect(enum.min_by {|o| o.nil? ? 1 : 0 }).to eq(true)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.min_by {|e| e.size}).to eq([1, 2])
  end

  describe "Enumerable with size" do
    before do
      @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          expect(@object.min_by.size).to eq(@object.size)
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
          expect(@object.min_by.size).to eq(nil)
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
        expect(@enum.min_by(2)).to be_an_instance_of(Enumerator)
      end
    end

    context "with a block" do
      it "returns an array containing the minimum n elements based on the block's value" do
        result = @enum.min_by(3) { |i| i.to_s }
        expect(result).to eq([1, 101, 20])
      end

      context "on a enumerable of length x where x < n" do
        it "returns an array containing the minimum n elements of length n" do
          result = @enum.min_by(500) { |i| i.to_s }
          expect(result.length).to eq(7)
        end
      end

      context "when n is negative" do
        it "raises an ArgumentError" do
          expect { @enum.min_by(-1) { |i| i.to_s } }.to raise_error(ArgumentError)
        end
      end
    end

    context "when n is nil" do
      it "returns the minimum element" do
        expect(@enum.min_by(nil) { |i| i.to_s }).to eq(1)
      end
    end
  end
end
