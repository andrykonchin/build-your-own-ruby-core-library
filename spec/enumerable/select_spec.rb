require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#select" do
  it "returns all elements for which the block is not false" do
    elements = (1..10).to_a
    enum = EnumerableSpecs::Numerous.new(*elements)

    expect(enum.select {|i| i % 3 == 0 }).to eq([3, 6, 9])
    expect(enum.select {|i| true }).to eq(elements)
    expect(enum.select {|i| false }).to eq([])
  end

  it "returns an enumerator when no block given" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.select).to be_an_instance_of(Enumerator)
    expect(enum.select.to_a).to eq([1, 2, 3, 4])
    expect(enum.select.each { |e| e < 3 }).to eq([1, 2])
  end

  describe "when #each yields multiple values" do
    it "yields multiple values as array when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.select {|e| yielded << e }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it "gathers whole arrays as elements when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.select {|e| true }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it "yields multiple values as array when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.select {|*args| yielded << args }
      expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
    end

    it "gathers multiple values as array when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.select {|*args| true }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.select.size).to eq(enum.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.select.size).to eq(nil)
        end
      end
    end
  end
end
