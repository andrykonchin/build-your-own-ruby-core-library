require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#group_by" do
  it "returns a hash with values grouped according to the block" do
    e = EnumerableSpecs::Numerous.new("foo", "bar", "baz")
    h = e.group_by { |word| word[0..0].to_sym }
    expect(h).to eq({ f: ["foo"], b: ["bar", "baz"]})
  end

  it "returns an empty hash for empty enumerables" do
    expect(EnumerableSpecs::Empty.new.group_by { |x| x}).to eq({})
  end

  it "returns a hash without default_proc" do
    e = EnumerableSpecs::Numerous.new("foo", "bar", "baz")
    h = e.group_by { |word| word[0..0].to_sym }
    expect(h[:some]).to be_nil
    expect(h.default_proc).to be_nil
    expect(h.default).to be_nil
  end

  it "returns an Enumerator if called without a block" do
    expect(EnumerableSpecs::Numerous.new.group_by).to be_an_instance_of(Enumerator)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    e = EnumerableSpecs::YieldsMulti.new
    h = e.group_by { |i| i }
    expect(h).to eq({ [1, 2] => [[1, 2]],
                  [6, 7, 8, 9] => [[6, 7, 8, 9]],
                  [3, 4, 5] => [[3, 4, 5]] })
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns the enumerable size" do
          expect(@object.group_by.size).to eq(@object.size)
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
          expect(@object.group_by.size).to eq(nil)
        end
      end
    end
  end
end
