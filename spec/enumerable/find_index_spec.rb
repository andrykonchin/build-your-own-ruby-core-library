require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#find_index" do
  before :each do
    @elements = [2, 4, 6, 8, 10]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
    @yieldsmixed = EnumerableSpecs::YieldsMixed2.new
  end

  it "passes each entry in enum to block while block when block is false" do
    visited_elements = []
    @numerous.find_index do |element|
      visited_elements << element
      false
    end
    expect(visited_elements).to eq(@elements)
  end

  it "returns nil when the block is false" do
    expect(@numerous.find_index {|e| false }).to eq(nil)
  end

  it "returns the first index for which the block is not false" do
    @elements.each_with_index do |element, index|
      expect(@numerous.find_index {|e| e > element - 1 }).to eq(index)
    end
  end

  it "returns the first index found" do
    repeated = [10, 11, 11, 13, 11, 13, 10, 10, 13, 11]
    numerous_repeat = EnumerableSpecs::Numerous.new(*repeated)
    repeated.each do |element|
      expect(numerous_repeat.find_index(element)).to eq(element - 10)
    end
  end

  it "returns nil when the element not found" do
    expect(@numerous.find_index(-1)).to eq(nil)
  end

  it "ignores the block if an argument is given" do
    expect {
      expect(@numerous.find_index(-1) {|e| true }).to eq(nil)
    }.to complain(/given block not used/)
  end

  it "returns an Enumerator if no block given" do
    expect(@numerous.find_index).to be_an_instance_of(Enumerator)
  end

  it "uses #== for testing equality" do
    expect([2].to_enum.find_index(2.0)).to eq(0)
    expect([2.0].to_enum.find_index(2)).to eq(0)
  end

  describe "without block" do
    it "gathers whole arrays as elements when each yields multiple" do
      expect(@yieldsmixed.find_index([0, 1, 2])).to eq(3)
    end
  end

  describe "with block" do
    before :each do
      ScratchPad.record []
    end

    after :each do
      ScratchPad.clear
    end

    describe "given a single yield parameter" do
      it "passes first element to the parameter" do
        @yieldsmixed.find_index {|a| ScratchPad << a; false }
        expect(ScratchPad.recorded).to eq(EnumerableSpecs::YieldsMixed2.first_yields)
      end
    end

    describe "given a greedy yield parameter" do
      it "passes a gathered array to the parameter" do
        @yieldsmixed.find_index {|*args| ScratchPad << args; false }
        expect(ScratchPad.recorded).to eq(EnumerableSpecs::YieldsMixed2.greedy_yields)
      end
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns nil" do
          expect(@object.find_index.size).to eq(nil)
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
          expect(@object.find_index.size).to eq(nil)
        end
      end
    end
  end
end
