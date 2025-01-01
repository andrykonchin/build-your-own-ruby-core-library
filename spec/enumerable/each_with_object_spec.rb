require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#each_with_object" do
  before :each do
    @values = [2, 5, 3, 6, 1, 4]
    @enum = EnumerableSpecs::Numerous.new(*@values)
    @initial = "memo"
  end

  it "passes each element and its argument to the block" do
    acc = []
    expect(@enum.each_with_object(@initial) do |elem, obj|
      expect(obj).to equal(@initial)
      obj = 42
      acc << elem
    end).to equal(@initial)
    expect(acc).to eq(@values)
  end

  it "returns an enumerator if no block" do
    acc = []
    e = @enum.each_with_object(@initial)
    expect(
      e.each do |elem, obj|
        expect(obj).to equal(@initial)
        obj = 42
        acc << elem
      end
    ).to equal(@initial)
    expect(acc).to eq(@values)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    array = []
    multi.each_with_object(array) { |elem, obj| obj << elem }
    expect(array).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
  end

  describe "Enumerable with size" do
    before :all do
      @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          expect(@object.each_with_object([]).size).to eq(@object.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    before :all do
      @object = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(@object.each_with_object([]).size).to eq(nil)
        end
      end
    end
  end
end
