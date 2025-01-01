require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#none?" do
  before :each do
    @empty = EnumerableSpecs::Empty.new
    @enum = EnumerableSpecs::Numerous.new
    @enum1 = EnumerableSpecs::Numerous.new(0, 1, 2, -1)
    @enum2 = EnumerableSpecs::Numerous.new(nil, false, true)
  end

  it "always returns true on empty enumeration" do
    expect(@empty.none?).to eq(true)
    expect(@empty.none? { true }).to eq(true)
  end

  it "raises an ArgumentError when more than 1 argument is provided" do
    expect { @enum.none?(1, 2, 3) }.to raise_error(ArgumentError)
  end

  it "does not hide exceptions out of #each" do
    expect {
      EnumerableSpecs::ThrowingEach.new.none?
    }.to raise_error(RuntimeError)

    expect {
      EnumerableSpecs::ThrowingEach.new.none? { false }
    }.to raise_error(RuntimeError)
  end

  describe "with no block" do
    it "returns true if none of the elements in self are true" do
      e = EnumerableSpecs::Numerous.new(false, nil, false)
      expect(e.none?).to be true
    end

    it "returns false if at least one of the elements in self are true" do
      e = EnumerableSpecs::Numerous.new(false, nil, true, false)
      expect(e.none?).to be false
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMultiWithFalse.new
      expect(multi.none?).to be false
    end
  end

  describe "with a block" do
    before :each do
      @e = EnumerableSpecs::Numerous.new(1,1,2,3,4)
    end

    it "passes each element to the block in turn until it returns true" do
      acc = []
      @e.none? {|e| acc << e; false }
      expect(acc).to eq([1,1,2,3,4])
    end

    it "stops passing elements to the block when it returns true" do
      acc = []
      @e.none? {|e| acc << e; e == 3 ? true : false }
      expect(acc).to eq([1,1,2,3])
    end

    it "returns true if the block never returns true" do
      expect(@e.none? {|e| false }).to be true
    end

    it "returns false if the block ever returns true" do
      expect(@e.none? {|e| e == 3 ? true : false }).to be false
    end

    it "does not hide exceptions out of the block" do
      expect {
        @enum.none? { raise "from block" }
      }.to raise_error(RuntimeError)
    end

    it "gathers initial args as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.none? { |e| yielded << e; false }
      expect(yielded).to eq([1, 3, 6])
    end

    it "yields multiple arguments when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.none? { |*args| yielded << args; false }
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe 'when given a pattern argument' do
    it "calls `===` on the pattern the return value " do
      pattern = EnumerableSpecs::Pattern.new { |x| x == 3 }
      expect(@enum1.none?(pattern)).to eq(true)
      expect(pattern.yielded).to eq([[0], [1], [2], [-1]])
    end

    it "always returns true on empty enumeration" do
      expect(@empty.none?(Integer)).to eq(true)
    end

    it "does not hide exceptions out of #each" do
      expect {
        EnumerableSpecs::ThrowingEach.new.none?(Integer)
      }.to raise_error(RuntimeError)
    end

    it "returns true if the pattern never returns a truthy value" do
      expect(@enum2.none?(Integer)).to eq(true)
      pattern = EnumerableSpecs::Pattern.new { |x| nil }
      expect(@enum.none?(pattern)).to eq(true)
    end

    it "returns false if the pattern ever returns other than false or nil" do
      pattern = EnumerableSpecs::Pattern.new { |x| x < 0 }
      expect(@enum1.none?(pattern)).to eq(false)
      expect(pattern.yielded).to eq([[0], [1], [2], [-1]])
    end

    it "does not hide exceptions out of pattern#===" do
      pattern = EnumerableSpecs::Pattern.new { raise "from pattern" }
      expect {
        @enum.none?(pattern)
      }.to raise_error(RuntimeError)
    end

    it "calls the pattern with gathered array when yielded with multiple arguments" do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      expect(multi.none?(pattern)).to eq(true)
      expect(pattern.yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
    end

    it "ignores the block if there is an argument" do
      expect {
        expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5).none?(String) { true }).to eq(true)
      }.to complain(/given block not used/)
    end
  end
end
