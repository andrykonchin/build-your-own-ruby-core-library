require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#one?" do
  before :each do
    @empty = EnumerableSpecs::Empty.new
    @enum = EnumerableSpecs::Numerous.new
    @enum1 = EnumerableSpecs::Numerous.new(0, 1, 2, -1)
    @enum2 = EnumerableSpecs::Numerous.new(nil, false, true)
  end

  it "always returns false on empty enumeration" do
    expect(@empty.one?).to eq(false)
    expect(@empty.one? { true }).to eq(false)
  end

  it "raises an ArgumentError when more than 1 argument is provided" do
    expect { @enum.one?(1, 2, 3) }.to raise_error(ArgumentError)
  end

  it "does not hide exceptions out of #each" do
    expect {
      EnumerableSpecs::ThrowingEach.new.one?
    }.to raise_error(RuntimeError)

    expect {
      EnumerableSpecs::ThrowingEach.new.one? { false }
    }.to raise_error(RuntimeError)
  end

  describe "with no block" do
      expect([false, nil, true].one?).to be true
    end

      expect([false, :value, nil, true].one?).to be false
    end

      expect([false, nil, false].one?).to be false
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMultiWithSingleTrue.new
      expect(multi.one?).to be false
    end
  end

  describe "with a block" do
      expect([:a, :b, :c].one? { |s| s == :a }).to be true
    end

      expect([:a, :b, :c].one? { |s| s == :a || s == :b }).to be false
    end

      expect([:a, :b, :c].one? { |s| s == :d }).to be false
    end

    it "does not hide exceptions out of the block" do
      expect {
        @enum.one? { raise "from block" }
      }.to raise_error(RuntimeError)
    end

    it "gathers initial args as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      expect(multi.one? { |e| yielded << e; false }).to eq(false)
      expect(yielded).to eq([1, 3, 6])
    end

    it "yields multiple arguments when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      expect(multi.one? { |*args| yielded << args; false }).to eq(false)
      expect(yielded).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe 'when given a pattern argument' do
    it "calls `===` on the pattern the return value " do
      pattern = EnumerableSpecs::Pattern.new { |x| x == 1 }
      expect(@enum1.one?(pattern)).to eq(true)
      expect(pattern.yielded).to eq([[0], [1], [2], [-1]])
    end

    it "always returns false on empty enumeration" do
      expect(@empty.one?(Integer)).to eq(false)
    end

    it "does not hide exceptions out of #each" do
      expect {
        EnumerableSpecs::ThrowingEach.new.one?(Integer)
      }.to raise_error(RuntimeError)
    end

    it "returns true if the pattern returns a truthy value only once" do
      expect(@enum2.one?(NilClass)).to eq(true)
      pattern = EnumerableSpecs::Pattern.new { |x| x == 2 }
      expect(@enum1.one?(pattern)).to eq(true)
    end

    it "returns false if the pattern returns a truthy value more than once" do
      pattern = EnumerableSpecs::Pattern.new { |x| !x }
      expect(@enum2.one?(pattern)).to eq(false)
      expect(pattern.yielded).to eq([[nil], [false]])
    end

    it "returns false if the pattern never returns a truthy value" do
      pattern = EnumerableSpecs::Pattern.new { |x| nil }
      expect(@enum1.one?(pattern)).to eq(false)
      expect(pattern.yielded).to eq([[0], [1], [2], [-1]])
    end

    it "does not hide exceptions out of pattern#===" do
      pattern = EnumerableSpecs::Pattern.new { raise "from pattern" }
      expect {
        @enum.one?(pattern)
      }.to raise_error(RuntimeError)
    end

    it "calls the pattern with gathered array when yielded with multiple arguments" do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      expect(multi.one?(pattern)).to eq(false)
      expect(pattern.yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
    end

    it "ignores the block if there is an argument" do
      expect {
        expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4, "5").one?(String) { false }).to eq(true)
      }.to complain(/given block not used/)
    end
  end
end
