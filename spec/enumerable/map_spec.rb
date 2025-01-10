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

  it "passes through the values yielded by #each_with_index" do
    EnumerableSpecs::Numerous.new(:a, :b).each_with_index.map { |x, i| ScratchPad << [x, i]; nil }
    expect(ScratchPad.recorded).to eq([[:a, 0], [:b, 1]])
  end

  it "gathers initial args as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.map {|e| e}).to eq([1,3,6])
  end

  it "only yields increasing values for a Range" do
    expect((1..0).map { |x| x }).to eq([])
    expect((1..1).map { |x| x }).to eq([1])
    expect((1..2).map { |x| x }).to eq([1, 2])
  end

  it "returns an enumerator when no block given" do
    enum = EnumerableSpecs::Numerous.new.map
    expect(enum).to be_an_instance_of(Enumerator)
    expect(enum.each { |i| -i }).to eq([-2, -5, -3, -6, -1, -4])
  end

  it "reports the same arity as the given block" do
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

  it "yields an Array of 2 elements for a Hash when block arity is 1" do
    c = Class.new do
      def register(a)
        ScratchPad << a
      end
    end
    m = c.new.method(:register)

    ScratchPad.record []
    { 1 => 'a', 2 => 'b' }.map(&m)
    expect(ScratchPad.recorded).to eq([[1, 'a'], [2, 'b']])
  end

  it "yields 2 arguments for a Hash when block arity is 2" do
    c = Class.new do
      def register(a, b)
        ScratchPad << [a, b]
      end
    end
    m = c.new.method(:register)

    ScratchPad.record []
    { 1 => 'a', 2 => 'b' }.map(&m)
    expect(ScratchPad.recorded).to eq([[1, 'a'], [2, 'b']])
  end

  it "calls the each method on sub-classes" do
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

  describe "Enumerable with size" do
    before do
      @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
    end

    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          expect(@object.map.size).to eq(@object.size)
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
          expect(@object.map.size).to eq(nil)
        end
      end
    end
  end
end
