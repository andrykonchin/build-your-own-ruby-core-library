require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#tally" do
  before :each do
    ScratchPad.record []
  end

  it "returns a Hash with counts according to the value" do
    enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
    expect(enum.tally).to eq({ 'foo' => 2, 'bar' => 1, 'baz' => 1})
  end

  it "returns a Hash without default" do
    hash = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz').tally
    expect(hash.default_proc).to be_nil
    expect(hash.default).to be_nil
  end

  it "returns an empty Hash for empty enumerables" do
    expect(EnumerableSpecs::Empty.new.tally).to eq({})
  end

  it "gathers whole arrays as elements when #each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.tally).to eq([1, 2] => 1, [3, 4, 5] => 1, [6, 7, 8, 9] => 1)
  end

  it "does not call given block" do
    enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
    enum.tally { |v| ScratchPad << v }
    expect(ScratchPad.recorded).to eq([])
  end

  describe "with a Hash argument" do
    it "returns the given Hash" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      hash = { 'foo' => 1 }
      expect(enum.tally(hash)).to equal(hash)
    end

    it "updates the given Hash with new keys" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar')
      expect(enum.tally('baz' => 1)).to eq('foo' => 1, 'bar' => 1, 'baz' => 1)
    end

    it "updates the given Hash and increments already present keys counts" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar')
      expect(enum.tally('foo' => 1)).to eq('foo' => 2, 'bar' => 1)
    end

    it "calls #to_hash to convert argument into Hash implicitly if passed not a Hash" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      object = double("hash", to_hash: { 'foo' => 1 })
      expect(enum.tally(object)).to eq({ 'foo' => 3, 'bar' => 1, 'baz' => 1})
    end

    it "raises a FrozenError and does not update the given Hash when the Hash is frozen" do
      enum = EnumerableSpecs::Numerous.new('foo', 'bar', 'foo', 'baz')
      hash = { 'foo' => 1 }.freeze
      expect { enum.tally(hash) }.to raise_error(FrozenError, %q{can't modify frozen Hash: {"foo" => 1}})
      expect(hash).to eq({ 'foo' => 1 })
    end

    it "raises a FrozenError the Hash is frozen even if enumerable is empty" do
      enum = EnumerableSpecs::Empty.new
      hash = { 'foo' => 1 }.freeze
      expect { enum.tally(hash) }.to raise_error(FrozenError, %q{can't modify frozen Hash: {"foo" => 1}})
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

    it "needs the values counting each elements to be an Integer" do
      enum = EnumerableSpecs::Numerous.new('foo')
      expect {
        enum.tally({ 'foo' => 'bar' })
      }.to raise_error(TypeError, "wrong argument type String (expected Integer)")
    end
  end
end
