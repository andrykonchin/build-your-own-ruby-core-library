require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#any?" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new
    @empty = EnumerableSpecs::Empty.new
    @enum1 = EnumerableSpecs::Numerous.new(0, 1, 2, -1)
    @enum2 = EnumerableSpecs::Numerous.new(nil, false, true)
  end

  it "always returns false on empty enumeration" do
    expect(@empty.any?).to be false
    expect(@empty.any? { nil }).to be false
  end

  it "raises an ArgumentError when more than 1 argument is provided" do
    expect { @enum.any?(1, 2, 3) }.to raise_error(ArgumentError)
  end

  it "does not hide exceptions out of #each" do
    expect {
      EnumerableSpecs::ThrowingEach.new.any?
    }.to raise_error(RuntimeError)

    expect {
      EnumerableSpecs::ThrowingEach.new.any? { false }
    }.to raise_error(RuntimeError)
  end

  describe "with no block" do
    it "returns true if any element is not false or nil" do
      expect(@enum.any?).to be true
      expect(@enum1.any?).to be true
      expect(@enum2.any?).to be true
      expect(EnumerableSpecs::Numerous.new(true).any?).to be true
      expect(EnumerableSpecs::Numerous.new('a','b','c').any?).to be true
      expect(EnumerableSpecs::Numerous.new('a','b','c', nil).any?).to be true
      expect(EnumerableSpecs::Numerous.new(1, nil, 2).any?).to be true
      expect(EnumerableSpecs::Numerous.new(1, false).any?).to be true
      expect(EnumerableSpecs::Numerous.new(false, nil, 1, false).any?).to be true
      expect(EnumerableSpecs::Numerous.new(false, 0, nil).any?).to be true
    end

    it "returns false if all elements are false or nil" do
      expect(EnumerableSpecs::Numerous.new(false).any?).to be false
      expect(EnumerableSpecs::Numerous.new(false, false).any?).to be false
      expect(EnumerableSpecs::Numerous.new(nil).any?).to be false
      expect(EnumerableSpecs::Numerous.new(nil, nil).any?).to be false
      expect(EnumerableSpecs::Numerous.new(nil, false, nil).any?).to be false
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMultiWithFalse.new
      expect(multi.any?).to be true
    end
  end

  describe "with block" do
    it "returns true if the block ever returns other than false or nil" do
      expect(@enum.any? { true }).to be true
      expect(@enum.any? { 0 }).to be true
      expect(@enum.any? { 1 }).to be true

      expect(@enum1.any? { Object.new }).to be true
      expect(@enum1.any?{ |o| o < 1 }).to be true
      expect(@enum1.any?{ |o| 5 }).to be true

      expect(@enum2.any? { |i| i == nil }).to be true
    end

    it "returns false if the block never returns other than false or nil" do
      expect(@enum.any? { false }).to be false
      expect(@enum.any? { nil }).to be false

      expect(@enum1.any?{ |o| o < -10 }).to be false
      expect(@enum1.any?{ |o| nil }).to be false

      expect(@enum2.any? { |i| i == :stuff }).to be false
    end

    it "stops iterating once the return value is determined" do
      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(:one, :two, :three).any? do |e|
          yielded << e
          false
        end
      ).to be false
      expect(yielded).to eq [:one, :two, :three]

      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(true, true, false, true).any? do |e|
          yielded << e
          e
        end
      ).to be true
      expect(yielded).to eq [true]

      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(false, nil, false, true, false).any? do |e|
          yielded << e
          e
        end
      ).to be true
      expect(yielded).to eq [false, nil, false, true]

      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5).any? do |e|
          yielded << e
          e
        end
      ).to be true
      expect(yielded).to eq [1]
    end

    it "does not hide exceptions out of the block" do
      expect {
        @enum.any? { raise "from block" }
      }.to raise_error(RuntimeError)
    end

    it "gathers initial args as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      expect(multi.any? { |e| yielded << e; false }).to be false
      expect(yielded).to eq [1, 3, 6]
    end

    it "yields multiple arguments when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      expect(multi.any? { |*args| yielded << args; false }).to be false
      expect(yielded).to eq [[1, 2], [3, 4, 5], [6, 7, 8, 9]]
    end
  end

  describe 'when given a pattern argument' do
    it "calls `#===` on the pattern the return value " do
      pattern = EnumerableSpecs::Pattern.new { |x| x == 2 }
      expect(@enum1.any?(pattern)).to be true
      expect(pattern.yielded).to eq [[0], [1], [2]]
    end

    it "always returns false on empty enumeration" do
      expect(@empty.any?(Integer)).to be false
    end

    it "does not hide exceptions out of #each" do
      expect {
        EnumerableSpecs::ThrowingEach.new.any?(Integer)
      }.to raise_error(RuntimeError)
    end

    it "returns true if the pattern ever returns a truthy value" do
      expect(@enum2.any?(NilClass)).to be true
      pattern = EnumerableSpecs::Pattern.new { |x| 42 }
      expect(@enum.any?(pattern)).to be true
    end

    it "returns false if the block never returns other than false or nil" do
      pattern = EnumerableSpecs::Pattern.new { |x| nil }
      expect(@enum1.any?(pattern)).to be false
      expect(pattern.yielded).to eq [[0], [1], [2], [-1]]
    end

    it "does not hide exceptions out of pattern#===" do
      pattern = EnumerableSpecs::Pattern.new { raise "from pattern" }
      expect {
        @enum.any?(pattern)
      }.to raise_error(RuntimeError)
    end

    it "calls the pattern with gathered array when yielded with multiple arguments" do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      expect(multi.any?(pattern)).to be false
      expect(pattern.yielded).to eq [[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]]
    end

    it "ignores the block if there is an argument" do
      expect {
        expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5).any?(String) { true }).to be false
      }.to complain(/given block not used/)
    end
  end
end
