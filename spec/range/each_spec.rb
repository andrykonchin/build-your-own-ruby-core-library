require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#each' do
  before do
    ScratchPad.record []
  end

  it 'passes each element of self to the block' do # rubocop:disable RSpec/RepeatedExample
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    range.each { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      ]
    )
  end

  it "doesn't yield self.end if end is excluded" do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    range.each { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3)
      ]
    )
  end

  it 'returns an Enumerator if no block given' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    e = range.each

    expect(e).to be_an_instance_of(Enumerator)
    expect(e.to_a).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      ]
    )
  end

  it 'returns self if block given' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.each {}).to equal(range)
  end

  it 'iterates calling #succ on current element to get the next one' do # rubocop:disable RSpec/RepeatedExample
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    range.each { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      ]
    )
  end

  it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
    range = Range.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))
    expect {
      range.each {}
    }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")

    range = Range.new(nil, RangeSpecs::WithSucc.new(4))
    expect {
      range.each {}
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  it 'works with endless ranges' do
    range = Range.new(RangeSpecs::WithSucc.new(-2), nil)
    range.each { |e| break if e.value > 2; ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(-2),
        RangeSpecs::WithSucc.new(-1),
        RangeSpecs::WithSucc.new(0),
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2)
      ]
    )
  end

  it 'yields nothing if backward range' do
    range = Range.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))

    range.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq([])
  end

  it 'yields nothing if empty range' do
    range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(1), true)

    range.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq([])
  end

  context 'String ranges' do
    it 'iterates until #succ returns a value that equals self.end' do
      range = Range.new('a', 'ab')

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%w[a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab])
    end

    it 'returns self if block given' do
      range = Range.new('a', 'c')
      expect(range.each {}).to equal(range)
    end

    it "doesn't yield self.end if end is excluded" do
      range = Range.new('a', 'c', true)
      range.each { |e| ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%w[a b])
    end

    it 'works with endless ranges' do
      range = Range.new('a', nil)
      range.each { |e| break if e > 'c'; ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%w[a b c])
    end

    it 'yields nothing if backward range' do
      range = Range.new('c', 'a')

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing if empty range' do
      range = Range.new('a', 'a', true)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end
  end

  context 'Symbol ranges' do
    it 'iterates until #succ returns a value that equals self.end' do
      range = Range.new(:a, :ab)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%i[a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab])
    end

    it "doesn't yield self.end if end is excluded" do
      range = Range.new(:a, :c, true)
      range.each { |e| ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%i[a b])
    end

    it 'works with endless ranges' do
      range = Range.new(:a, nil)
      range.each { |e| break if e > :c; ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%i[a b c])
    end

    it 'yields nothing if backward range' do
      range = Range.new(:c, :a)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing if empty range' do
      range = Range.new(:a, :a, true)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end
  end

  describe 'finit range' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the range size when Numeric range' do
          range = Range.new(1, 4)
          expect(range.each.size).to eq(range.size)

          range = Range.new(4, 1)
          expect(range.each.size).to eq(range.size)

          range = Range.new(1, Float::INFINITY)
          expect(range.each.size).to eq(range.size)
        end

        it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
          range = Range.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))

          expect {
            range.each.size
          }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")
        end

        it 'size returns the range size when non-Numeric range' do
          range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
          expect(range.each.size).to eq(range.size)
        end
      end
    end
  end

  describe 'infinit range' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns range size' do
          range = Range.new(1, nil)
          expect(range.each.size).to eq(range.size)

          range = Range.new(RangeSpecs::WithSucc.new(1), nil)
          expect(range.each.size).to eq(range.size)
        end
      end
    end
  end
end
