require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#each_with_index" do
  before :each do
    @b = EnumerableSpecs::Numerous.new(2, 5, 3, 6, 1, 4)
  end

  it "passes each element and its index to block" do
    @a = []
    @b.each_with_index { |o, i| @a << [o, i] }
    expect(@a).to eq([[2, 0], [5, 1], [3, 2], [6, 3], [1, 4], [4, 5]])
  end

  it "provides each element to the block" do
    acc = []
    obj = EnumerableSpecs::EachDefiner.new()
    res = obj.each_with_index {|a,i| acc << [a,i]}
    expect(acc).to eq([])
    expect(obj).to eq(res)
  end

  it "provides each element to the block and its index" do
    acc = []
    res = @b.each_with_index {|a,i| acc << [a,i]}
    expect([[2, 0], [5, 1], [3, 2], [6, 3], [1, 4], [4, 5]]).to eq(acc)
    expect(res).to eql(@b)
  end

  it "binds splat arguments properly" do
    acc = []
    res = @b.each_with_index { |*b| c,d = b; acc << c; acc << d }
    expect([2, 0, 5, 1, 3, 2, 6, 3, 1, 4, 4, 5]).to eq(acc)
    expect(res).to eql(@b)
  end

  it "returns an enumerator if no block" do
    e = @b.each_with_index
    expect(e).to be_an_instance_of(Enumerator)
    expect(e.to_a).to eq([[2, 0], [5, 1], [3, 2], [6, 3], [1, 4], [4, 5]])
  end

  it "passes extra parameters to each" do
    count = EnumerableSpecs::EachCounter.new(:apple)
    e = count.each_with_index(:foo, :bar)
    expect(e.to_a).to eq([[:apple, 0]])
    expect(count.arguments_passed).to eq([:foo, :bar])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.each_with_index.size).to eq(@object.size)
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
          expect(@object.each_with_index.size).to eq(nil)
        end
      end
    end
  end
end
