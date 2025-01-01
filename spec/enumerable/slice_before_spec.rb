require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#slice_before" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(7,6,5,4,3,2,1)
  end

  describe "when given an argument and no block" do
    it "calls #=== on the argument to determine when to yield" do
      arg = double "filter"
      expect(arg).to receive(:===).and_return(false, true, false, false, false, true, false)
      e = @enum.slice_before(arg)
      expect(e).to be_an_instance_of(Enumerator)
      expect(e.to_a).to eq([[7], [6, 5, 4, 3], [2, 1]])
    end

    it "doesn't yield an empty array if the filter matches the first entry or the last entry" do
      arg = double "filter"
      expect(arg).to receive(:===).exactly(7).and_return(true)
      e = @enum.slice_before(arg)
      expect(e.to_a).to eq([[7], [6], [5], [4], [3], [2], [1]])
    end

    it "uses standard boolean as a test" do
      arg = double "filter"
      expect(arg).to receive(:===).and_return(false, :foo, nil, false, false, 42, false)
      e = @enum.slice_before(arg)
      expect(e.to_a).to eq([[7], [6, 5, 4, 3], [2, 1]])
    end
  end

  describe "when given a block" do
    describe "and no argument" do
      it "calls the block to determine when to yield" do
        e = @enum.slice_before{|i| i == 6 || i == 2}
        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq([[7], [6, 5, 4, 3], [2, 1]])
      end
    end

    it "does not accept arguments" do
      expect {
        @enum.slice_before(1) {}
      }.to raise_error(ArgumentError)
    end
  end

  it "raises an ArgumentError when given an incorrect number of arguments" do
    expect { @enum.slice_before("one", "two") }.to raise_error(ArgumentError)
    expect { @enum.slice_before }.to raise_error(ArgumentError)
  end

  describe "when an iterator method yields more than one value" do
    it "processes all yielded values" do
      enum = EnumerableSpecs::YieldsMulti.new
      result = enum.slice_before { |i| i == [3, 4, 5] }.to_a
      expect(result).to eq([[[1, 2]], [[3, 4, 5], [6, 7, 8, 9]]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns nil" do
          expect(@object.slice_before(3).size).to eq(nil)
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
          expect(@object.slice_before(3).size).to eq(nil)
        end
      end
    end
  end
end
