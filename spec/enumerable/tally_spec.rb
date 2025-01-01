require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#tally" do
  before :each do
    ScratchPad.record []
  end

  it "returns a hash with counts according to the value" do
    enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
    expect(enum.tally).to eq({ 'foo' => 2, 'bar' => 1, 'baz' => 1})
  end

  it "returns a hash without default" do
    hash = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz').tally
    expect(hash.default_proc).to be_nil
    expect(hash.default).to be_nil
  end

  it "returns an empty hash for empty enumerables" do
    expect(EnumerableSpecs::Empty.new.tally).to eq({})
  end

  it "counts values as gathered array when yielded with multiple arguments" do
    expect(EnumerableSpecs::YieldsMixed2.new.tally).to eq(EnumerableSpecs::YieldsMixed2.gathered_yields.group_by(&:itself).transform_values(&:size))
  end

  it "does not call given block" do
    enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
    enum.tally { |v| ScratchPad << v }
    expect(ScratchPad.recorded).to eq([])
  end

  describe "with a hash" do
    it "returns a hash with counts according to the value" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      expect(enum.tally({ 'foo' => 1 })).to eq({ 'foo' => 3, 'bar' => 1, 'baz' => 1})
    end

    it "returns the given hash" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      hash = { 'foo' => 1 }
      expect(enum.tally(hash)).to equal(hash)
    end

    it "calls #to_hash to convert argument to Hash implicitly if passed not a Hash" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      object = Object.new
      def object.to_hash; { 'foo' => 1 }; end
      expect(enum.tally(object)).to eq({ 'foo' => 3, 'bar' => 1, 'baz' => 1})
    end

    it "raises a FrozenError and does not update the given hash when the hash is frozen" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      hash = { 'foo' => 1 }.freeze
      expect { enum.tally(hash) }.to raise_error(FrozenError)
      expect(hash).to eq({ 'foo' => 1 })
    end

    it "raises a FrozenError even if enumerable is empty" do
      enum = EnumerableSpecs::Numerous.new()
      hash = { 'foo' => 1 }.freeze
      expect { enum.tally(hash) }.to raise_error(FrozenError)
    end

    it "does not call given block" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      enum.tally({ 'foo' => 1 }) { |v| ScratchPad << v }
      expect(ScratchPad.recorded).to eq([])
    end

    it "ignores the default value" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      expect(enum.tally(Hash.new(100))).to eq({ 'foo' => 2, 'bar' => 1, 'baz' => 1})
    end

    it "ignores the default proc" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      expect(enum.tally(Hash.new {100})).to eq({ 'foo' => 2, 'bar' => 1, 'baz' => 1})
    end

    it "needs the values counting each elements to be an integer" do
      enum = EnumerableSpecs::Numerous.new('foo')
      expect { enum.tally({ 'foo' => 'bar' }) }.to raise_error(TypeError)
    end
  end
end
