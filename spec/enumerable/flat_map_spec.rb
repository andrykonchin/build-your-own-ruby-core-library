require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#flat_map" do
  it "yields elements to the block and flattens one level" do
    numerous = EnumerableSpecs::Numerous.new(1, [2, 3], [4, [5, 6]], {foo: :bar})
    expect(numerous.flat_map { |i| i }).to eq([1, 2, 3, 4, [5, 6], {foo: :bar}])
  end

  it "appends non-Array elements that do not define #to_ary" do
    obj = double("to_ary undefined")

    numerous = EnumerableSpecs::Numerous.new(1, obj, 2)
    expect(numerous.flat_map { |i| i }).to eq([1, obj, 2])
  end

  it "concatenates the result of calling #to_ary if it returns an Array" do
    obj = double("to_ary defined")
    expect(obj).to receive(:to_ary).and_return([:a, :b])

    numerous = EnumerableSpecs::Numerous.new(1, obj, 2)
    expect(numerous.flat_map { |i| i }).to eq([1, :a, :b, 2])
  end

  it "does not call #to_a" do
    obj = double("to_ary undefined")
    expect(obj).not_to receive(:to_a)

    numerous = EnumerableSpecs::Numerous.new(1, obj, 2)
    expect(numerous.flat_map { |i| i }).to eq([1, obj, 2])
  end

  it "appends an element that defines #to_ary that returns nil" do
    obj = double("to_ary defined")
    expect(obj).to receive(:to_ary).and_return(nil)

    numerous = EnumerableSpecs::Numerous.new(1, obj, 2)
    expect(numerous.flat_map { |i| i }).to eq([1, obj, 2])
  end

  it "raises a TypeError if an element defining #to_ary does not return an Array or nil"  do
    obj = double("to_ary defined")
    expect(obj).to receive(:to_ary).and_return("array")

    expect { [1, obj, 3].flat_map { |i| i } }.to raise_error(TypeError)
  end

  it "returns an enumerator when no block given" do
    enum = EnumerableSpecs::Numerous.new(1, 2).flat_map
    expect(enum).to be_an_instance_of(Enumerator)
    expect(enum.each{ |i| [i] * i }).to eq([1, 2, 2])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.flat_map.size).to eq(@object.size)
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
          expect(@object.flat_map.size).to eq(nil)
        end
      end
    end
  end
end
