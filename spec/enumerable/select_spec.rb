require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#select" do
  before :each do
    ScratchPad.record []
    @elements = (1..10).to_a
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  it "returns all elements for which the block is not false" do
    expect(@numerous.select {|i| i % 3 == 0 }).to eq([3, 6, 9])
    expect(@numerous.select {|i| true }).to eq(@elements)
    expect(@numerous.select {|i| false }).to eq([])
  end

  it "returns an enumerator when no block given" do
    expect(@numerous.select).to be_an_instance_of(Enumerator)
  end

  it "passes through the values yielded by #each_with_index" do
    [:a, :b].each_with_index.select { |x, i| ScratchPad << [x, i] }
    expect(ScratchPad.recorded).to eq([[:a, 0], [:b, 1]])
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.select {|e| e == [3, 4, 5] }).to eq([[3, 4, 5]])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.select.size).to eq(@object.size)
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
          expect(@object.select.size).to eq(nil)
        end
      end
    end
  end
end
