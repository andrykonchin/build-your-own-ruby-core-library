require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#map" do
  before :each do
    ScratchPad.record []
  end

  it "returns a new array with the results of passing each element to block" do
    entries = [0, 1, 3, 4, 5, 6]
    numerous = EnumerableSpecs::Numerous.new(*entries)
    expect(numerous.map { |i| i % 2 }).to eq([0, 1, 1, 0, 1, 0])
    expect(numerous.map { |i| i }).to eq(entries)
  end

  it "gathers initial args as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.map {|e| e}).to eq([1,3,6])
  end

  it "returns an enumerator when no block given" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.map).to be_an_instance_of(Enumerator)
    expect(enum.map.to_a).to eq([1, 2, 3, 4])
    expect(enum.map.each { |i| -i }).to eq([-1, -2, -3, -4])
  end

  it "reports the same arity as the given block" do
    pending "is not trivial to implement"

    entries = [0, 1, 3, 4, 5, 6]
    numerous = EnumerableSpecs::Numerous.new(*entries)

    def numerous.each(&block)
      ScratchPad << block.arity
      super
    end

    expect(numerous.map { |a, b| a % 2 }).to eq([0, 1, 1, 0, 1, 0])
    expect(ScratchPad.recorded).to eq([2])
    ScratchPad.clear
    ScratchPad.record []
    expect(numerous.map { |i| i }).to eq(entries)
    expect(ScratchPad.recorded).to eq([1])
  end

  it "calls the each method on sub-classes" do # TODO: replace Array with object
    c = Class.new(Hash) do
      def each
        ScratchPad << 'in each'
        super
      end
    end
    h = c.new
    h[1] = 'a'
    ScratchPad.record []
    h.map { |k,v| v }
    expect(ScratchPad.recorded).to eq(['in each'])
  end

  describe "when #each yields multiple values" do
    it "yields multiple values as array when block accepts a single parameter" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.map {|e| yielded << e; e }
      expect(yielded).to eq([1, 3, 6])
    end

    it "yields multiple arguments when block accepts multiple parameters" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.map { |*args| yielded << args; args }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.map.size).to eq(enum.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).map.size).to eq(nil)
        end
      end
    end
  end
end
