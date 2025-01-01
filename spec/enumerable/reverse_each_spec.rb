require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#reverse_each" do
  it "traverses enum in reverse order and pass each element to block" do
    a=[]
    EnumerableSpecs::Numerous.new.reverse_each { |i| a << i }
    expect(a).to eq([4, 1, 6, 3, 5, 2])
  end

  it "returns an Enumerator if no block given" do
    enum = EnumerableSpecs::Numerous.new.reverse_each
    expect(enum).to be_an_instance_of(Enumerator)
    expect(enum.to_a).to eq([4, 1, 6, 3, 5, 2])
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.reverse_each {|e| yielded << e }
    expect(yielded).to eq([[6, 7, 8, 9], [3, 4, 5], [1, 2]])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.reverse_each.size).to eq(@object.size)
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
          expect(@object.reverse_each.size).to eq(nil)
        end
      end
    end
  end
end
