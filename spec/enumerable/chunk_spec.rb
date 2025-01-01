require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#chunk" do
  before do
    ScratchPad.record []
  end

  it "returns an Enumerator if called without a block" do
    chunk = EnumerableSpecs::Numerous.new(1, 2, 3, 1, 2).chunk
    expect(chunk).to be_an_instance_of(Enumerator)

    result = chunk.with_index {|elt, i| elt - i }.to_a
    expect(result).to eq [[1, [1, 2, 3]], [-2, [1, 2]]]
  end

  it "returns an Enumerator if given a block" do
    expect(EnumerableSpecs::Numerous.new.chunk {}).to be_an_instance_of(Enumerator)
  end

  it "yields the current element and the current chunk to the block" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3)
    e.chunk { |x| ScratchPad << x }.to_a
    expect(ScratchPad.recorded).to eq [1, 2, 3]
  end

  it "returns elements of the Enumerable in an Array of Arrays, [v, ary], where 'ary' contains the consecutive elements for which the block returned the value 'v'" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 3, 2, 1)
    result = e.chunk { |x| x < 3 && 1 || 0 }.to_a
    expect(result).to eq [[1, [1, 2]], [0, [3]], [1, [2]], [0, [3]], [1, [2, 1]]]
  end

  it "returns a partitioned Array of values" do
    e = EnumerableSpecs::Numerous.new(1,2,3)
    expect(e.chunk { |x| x > 2 }.map(&:last)).to eq [[1, 2], [3]]
  end

  it "returns elements for which the block returns :_alone in separate Arrays" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 1)
    result = e.chunk { |x| x < 2 && :_alone }.to_a
    expect(result).to eq [[:_alone, [1]], [false, [2, 3, 2]], [:_alone, [1]]]
  end

  it "yields Arrays as a single argument to a rest argument" do
    e = EnumerableSpecs::Numerous.new([1, 2])
    e.chunk { |*x| ScratchPad << x }.to_a
    expect(ScratchPad.recorded).to eq [[[1,2]]]
  end

  it "does not return elements for which the block returns :_separator" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 3, 2, 1)
    result = e.chunk { |x| x == 2 ? :_separator : 1 }.to_a
    expect(result).to eq [[1, [1]], [1, [3, 3]], [1, [1]]]
  end

  it "does not return elements for which the block returns nil" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 1)
    result = e.chunk { |x| x == 2 ? nil : 1 }.to_a
    expect(result).to eq [[1, [1]], [1, [3]], [1, [1]]]
  end

  it "raises a RuntimeError if the block returns a Symbol starting with an underscore other than :_alone or :_separator" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3, 2, 1)
    expect { e.chunk { |x| :_arbitrary }.to_a }.to raise_error(RuntimeError)
  end

  it "does not accept arguments" do
    e = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect {
      e.chunk(1) {}
    }.to raise_error(ArgumentError)
  end

  it 'returned Enumerator size returns nil' do
    e = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 2, 1)
    enum = e.chunk { |x| true }
    expect(enum.size).to be nil
  end
end
