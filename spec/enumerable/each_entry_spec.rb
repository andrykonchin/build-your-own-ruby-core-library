require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#each_entry" do
  before :each do
    ScratchPad.record []
    @enum = EnumerableSpecs::YieldsMixed.new
    @entries = [1, [2], [3,4], [5,6,7], [8,9], nil, []]
  end

  it "yields multiple arguments as an array" do
    acc = []
    expect(@enum.each_entry {|g| acc << g}).to equal(@enum)
    expect(acc).to eq(@entries)
  end

  it "returns an enumerator if no block" do
    e = @enum.each_entry
    expect(e).to be_an_instance_of(Enumerator)
    expect(e.to_a).to eq(@entries)
  end

  it "passes through the values yielded by #each_with_index" do
    [:a, :b].each_with_index.each_entry { |x, i| ScratchPad << [x, i] }
    expect(ScratchPad.recorded).to eq([[:a, 0], [:b, 1]])
  end

  it "raises an ArgumentError when extra arguments" do
    expect { @enum.each_entry("one").to_a   }.to raise_error(ArgumentError)
    expect { @enum.each_entry("one"){}.to_a }.to raise_error(ArgumentError)
  end

  it "passes extra arguments to #each" do
    enum = EnumerableSpecs::EachCounter.new(1, 2)
    expect(enum.each_entry(:foo, "bar").to_a).to eq([1,2])
    expect(enum.arguments_passed).to eq([:foo, "bar"])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.each_entry.size).to eq(@object.size)
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
          expect(@object.each_entry.size).to eq(nil)
        end
      end
    end
  end
end
