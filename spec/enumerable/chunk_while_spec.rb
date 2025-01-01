require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#chunk_while" do
  before :each do
    ary = [10, 9, 7, 6, 4, 3, 2, 1]
    @enum = EnumerableSpecs::Numerous.new(*ary)
    @result = @enum.chunk_while { |i, j| i - 1 == j }
    @enum_length = ary.length
  end

  context "when given a block" do
    it "returns an enumerator" do
      expect(@result).to be_an_instance_of(Enumerator)
    end

    it "splits chunks between adjacent elements i and j where the block returns false" do
      expect(@result.to_a).to eq [[10, 9], [7, 6], [4, 3, 2, 1]]
    end

    it "calls the block for length of the receiver enumerable minus one times" do
      times_called = 0
      @enum.chunk_while do |i, j|
        times_called += 1
        i - 1 == j
      end.to_a
      expect(times_called).to eq(@enum_length - 1)
    end
  end

  context "when not given a block" do
    it "raises an ArgumentError" do
      expect { @enum.chunk_while }.to raise_error(ArgumentError)
    end
  end

  context "on a single-element array" do
    it "ignores the block and returns an enumerator that yields [element]" do
      expect([1].chunk_while {|x| x.even?}.to_a).to eq [[1]]
    end
  end
end
