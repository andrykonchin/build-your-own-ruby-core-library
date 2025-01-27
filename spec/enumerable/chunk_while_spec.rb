require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#chunk_while" do
  context "when given a block" do
    it "returns an enumerator" do
      enum = EnumerableSpecs::Numerous.new
      expect(enum.chunk_while { |i, j| true }).to be_an_instance_of(Enumerator)
    end

    it "yields each element with the next one" do
      enum = EnumerableSpecs::Numerous.new(10, 9, 7, 6, 4, 3, 2, 1)
      yielded = []
      enum.chunk_while { |i, j| yielded << [i, j] ; i - 1 == j }.to_a
      expect(yielded).to eq([[10, 9], [9, 7], [7, 6], [6, 4], [4, 3], [3, 2], [2, 1]])
    end

    it "splits chunks between adjacent elements i and j where the block returns false" do
      enum = EnumerableSpecs::Numerous.new(10, 9, 7, 6, 4, 3, 2, 1)
      result = enum.chunk_while { |i, j| i - 1 == j }
      expect(result.to_a).to eq [[10, 9], [7, 6], [4, 3, 2, 1]]
    end

    it "calls the block for length of the receiver enumerable minus one times" do
      array = [10, 9, 7, 6, 4, 3, 2, 1]
      enum = EnumerableSpecs::Numerous.new(*array)
      enum_length = array.length

      times_called = 0
      enum.chunk_while do |i, j|
        times_called += 1
        i - 1 == j
      end.to_a
      expect(times_called).to eq(enum_length - 1)
    end
  end

  context "when not given a block" do
    it "raises an ArgumentError" do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.chunk_while }.to raise_error(ArgumentError, "tried to create Proc object without a block")
    end
  end

  context "on a single-element enumerable" do
    it "ignores the block and returns an enumerator that yields [element]" do
      enum = EnumerableSpecs::Numerous.new(1)
      expect(enum.chunk_while {|x| x.even?}.to_a).to eq [[1]]
    end
  end

  describe "when #each yields multiple values" do
    it "yields multiple values as array when block accepts two parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.chunk_while {|i, j| yielded << [i, j]; true }.to_a
      expect(yielded).to eq([[[1, 2], [3, 4, 5]], [[3, 4, 5], [6, 7, 8, 9]]])
    end

    it "gathers whole arrays as elements when block accepts two parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      result = multi.chunk_while {|i, j| i.length.even? }.to_a
      expect(result).to eq([[[1, 2], [3, 4, 5]], [[6, 7, 8, 9]]])
    end

    it "yields multiple values as array when block accepts more than two parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.chunk_while {|*args| yielded << args; true }.to_a
      expect(yielded).to eq([[[1, 2], [3, 4, 5]], [[3, 4, 5], [6, 7, 8, 9]]])
    end

    it "gathers whole arrays as elements when block accepts more than two parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      result = multi.chunk_while {|*args| args[0].length.even? }.to_a
      expect(result).to eq([[[1, 2], [3, 4, 5]], [[6, 7, 8, 9]]])
    end
  end

  describe "Enumerable with size" do
    context "when a block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4).chunk_while {}.size).to eq(nil)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    context "when a block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).chunk_while {}.size).to eq(nil)
        end
      end
    end
  end
end
