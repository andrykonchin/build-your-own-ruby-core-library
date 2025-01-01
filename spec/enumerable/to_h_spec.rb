require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#to_h" do
  it "converts empty enumerable to empty hash" do
    enum = EnumerableSpecs::EachDefiner.new
    expect(enum.to_h).to eq({})
  end

  it "converts yielded [key, value] pairs to a hash" do
    enum = EnumerableSpecs::EachDefiner.new([:a, 1], [:b, 2])
    expect(enum.to_h).to eq({ a: 1, b: 2 })
  end

  it "uses the last value of a duplicated key" do
    enum = EnumerableSpecs::EachDefiner.new([:a, 1], [:b, 2], [:a, 3])
    expect(enum.to_h).to eq({ a: 3, b: 2 })
  end

  it "calls #to_ary on contents" do
    pair = double('to_ary')
    expect(pair).to receive(:to_ary).and_return([:b, 2])
    enum = EnumerableSpecs::EachDefiner.new([:a, 1], pair)
    expect(enum.to_h).to eq({ a: 1, b: 2 })
  end

  it "forwards arguments to #each" do
    enum = Object.new
    def enum.each(*args)
      yield(*args)
      yield([:b, 2])
    end
    enum.extend Enumerable
    expect(enum.to_h(:a, 1)).to eq({ a: 1, b: 2 })
  end

  it "raises TypeError if an element is not an array" do
    enum = EnumerableSpecs::EachDefiner.new(:x)
    expect { enum.to_h }.to raise_error(TypeError)
  end

  it "raises ArgumentError if an element is not a [key, value] pair" do
    enum = EnumerableSpecs::EachDefiner.new([:x])
    expect { enum.to_h }.to raise_error(ArgumentError)
  end

  context "with block" do
    before do
      @enum = EnumerableSpecs::EachDefiner.new(:a, :b)
    end

    it "converts [key, value] pairs returned by the block to a hash" do
      expect(@enum.to_h { |k| [k, k.to_s] }).to eq({ a: 'a', b: 'b' })
    end

    it "passes to a block each element as a single argument" do
      enum_of_arrays = EnumerableSpecs::EachDefiner.new([:a, 1], [:b, 2])

      ScratchPad.record []
      enum_of_arrays.to_h { |*args| ScratchPad << args; [args[0], args[1]] }
      expect(ScratchPad.recorded.sort).to eq([[[:a, 1]], [[:b, 2]]])
    end

    it "raises ArgumentError if block returns longer or shorter array" do
      expect do
        @enum.to_h { |k| [k, k.to_s, 1] }
      end.to raise_error(ArgumentError, /element has wrong array length/)

      expect do
        @enum.to_h { |k| [k] }
      end.to raise_error(ArgumentError, /element has wrong array length/)
    end

    it "raises TypeError if block returns something other than Array" do
      expect do
        @enum.to_h { |k| "not-array" }
      end.to raise_error(TypeError, /wrong element type String/)
    end

    it "coerces returned pair to Array with #to_ary" do
      x = double('x', to_ary: [:b, 'b'])
      expect(@enum.to_h { |k| x }).to eq({ :b => 'b' })
    end

    it "does not coerce returned pair to Array with #to_a" do
      x = double('x', to_a: [:b, 'b'])

      expect do
        @enum.to_h { |k| x }
      end.to raise_error(TypeError, /wrong element type RSpec::Mocks::Double/)
    end
  end
end
