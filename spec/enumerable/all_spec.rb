require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#all?" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new
    @empty = EnumerableSpecs::Empty.new()
    @enum1 = EnumerableSpecs::Numerous.new(0, 1, 2, -1)
    @enum2 = EnumerableSpecs::Numerous.new(nil, false, true)
  end

  it "always returns true on empty enumeration" do
    expect(@empty.all?).to be true
    expect(@empty.all? { nil }).to be true
  end

  it "raises an ArgumentError when more than 1 argument is provided" do
    expect { @enum.all?(1, 2, 3) }.to raise_error(ArgumentError)
  end

  it "does not hide exceptions out of #each" do
    expect {
      EnumerableSpecs::ThrowingEach.new.all?
    }.to raise_error(RuntimeError)

    expect {
      EnumerableSpecs::ThrowingEach.new.all? { false }
    }.to raise_error(RuntimeError)
  end

  describe "with no block" do
    it "returns true if no elements are false or nil" do
      expect(@enum.all?).to be true
      expect(@enum1.all?).to be true
      expect(@enum2.all?).not_to be true

      expect(EnumerableSpecs::Numerous.new('a','b','c').all?).to be true
      expect(EnumerableSpecs::Numerous.new(0, "x", true).all?).to be true
    end

    it "returns false if there are false or nil elements" do
      expect(EnumerableSpecs::Numerous.new(false).all?).to be false
      expect(EnumerableSpecs::Numerous.new(false, false).all?).to be false

      expect(EnumerableSpecs::Numerous.new(nil).all?).to be false
      expect(EnumerableSpecs::Numerous.new(nil, nil).all?).to be false

      expect(EnumerableSpecs::Numerous.new(1, nil, 2).all?).to be false
      expect(EnumerableSpecs::Numerous.new(0, "x", false, true).all?).to be false
      expect(@enum2.all?).to be false
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMultiWithFalse.new
      expect(multi.all?).to be true
    end
  end

  describe "with block" do
    it "returns true if the block never returns false or nil" do
      expect(@enum.all? { true }).to be true
      expect(@enum1.all?{ |o| o < 5 }).to be true
      expect(@enum1.all?{ |o| 5 }).to be true
    end

    it "returns false if the block ever returns false or nil" do
      expect(@enum.all? { false }).to be false
      expect(@enum.all? { nil }).to be false
      expect(@enum1.all? { |o| o > 2 }).to be false

      expect(EnumerableSpecs::Numerous.new.all? { |i| i > 5 }).to be false
      expect(EnumerableSpecs::Numerous.new.all? { |i| i == 3 ? nil : true }).to be false
    end

    it "stops iterating once the return value is determined" do
      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(:one, :two, :three).all? do |e|
          yielded << e
          false
        end
      ).to be false
      expect(yielded).to eq [:one]

      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(true, true, false, true).all? do |e|
          yielded << e
          e
        end
      ).to be false
      expect(yielded).to eq [true, true, false]

      yielded = []
      expect(
        EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5).all? do |e|
          yielded << e
          e
        end
      ).to be true
      expect(yielded).to eq [1, 2, 3, 4, 5]
    end

    it "does not hide exceptions out of the block" do
      expect {
        @enum.all? { raise "from block" }
      }.to raise_error(RuntimeError)
    end

    it "gathers initial args as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      expect(multi.all? { |e| yielded << e }).to be true
      expect(yielded).to eq [1, 3, 6]
    end

    it "yields multiple arguments when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      expect(multi.all? { |*args| yielded << args }).to be true
      expect(yielded).to eq [[1, 2], [3, 4, 5], [6, 7, 8, 9]]
    end
  end

  describe 'when given a pattern argument' do
    it "calls `#===` on the pattern the return value " do
      pattern = EnumerableSpecs::Pattern.new { |x| x >= 0 }
      expect(@enum1.all?(pattern)).to be false
      expect(pattern.yielded).to eq [[0], [1], [2], [-1]]
    end

    it "always returns true on empty enumeration" do
      expect(@empty.all?(Integer)).to be true
    end

    it "does not hide exceptions out of #each" do
      expect {
        EnumerableSpecs::ThrowingEach.new.all?(Integer)
      }.to raise_error(RuntimeError)
    end

    it "returns true if the pattern never returns false or nil" do
      pattern = EnumerableSpecs::Pattern.new { |x| 42 }
      expect(@enum.all?(pattern)).to be true
    end

    it "returns false if the pattern ever returns false or nil" do
      pattern = EnumerableSpecs::Pattern.new { |x| x >= 0 }
      expect(@enum1.all?(pattern)).to be false
      expect(pattern.yielded).to eq [[0], [1], [2], [-1]]
    end

    it "does not hide exceptions out of pattern#===" do
      pattern = EnumerableSpecs::Pattern.new { raise "from pattern" }
      expect {
        @enum.all?(pattern)
      }.to raise_error(RuntimeError)
    end

    it "calls the pattern with gathered array when yielded with multiple arguments" do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { true }
      expect(multi.all?(pattern)).to be true
      expect(pattern.yielded).to eq [[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]]
    end

    it "ignores the block if there is an argument" do
      expect {
        expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5).all?(String) { true }).to be false
      }.to complain(/given block not used/)
    end
  end
end
