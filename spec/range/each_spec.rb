# Copyright (c) 2025 Andrii Konchyn
# Copyright (c) 2008 Engine Yard, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#each' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  before do
    ScratchPad.record []
  end

  it 'passes each element of self to the block' do # rubocop:disable RSpec/RepeatedExample
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
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
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
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
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
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
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.each {}).to equal(range)
  end

  it 'iterates calling #succ on current element to get the next one' do # rubocop:disable RSpec/RepeatedExample
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
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
    range = described_class.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))
    expect {
      range.each {}
    }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")

    range = described_class.new(nil, RangeSpecs::WithSucc.new(4))
    expect {
      range.each {}
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  it 'works with endless ranges' do
    range = described_class.new(RangeSpecs::WithSucc.new(-2), nil)
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
    range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))

    range.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq([])
  end

  it 'yields nothing if empty range' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(1), true)

    range.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq([])
  end

  context 'String ranges' do
    it 'iterates until #succ returns a value that equals self.end' do
      range = described_class.new('a', 'ab')

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%w[a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab])
    end

    it 'returns self if block given' do
      range = described_class.new('a', 'c')
      expect(range.each {}).to equal(range)
    end

    it "doesn't yield self.end if end is excluded" do
      range = described_class.new('a', 'c', true)
      range.each { |e| ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%w[a b])
    end

    it 'works with endless ranges' do
      range = described_class.new('a', nil)
      range.each { |e| break if e > 'c'; ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%w[a b c])
    end

    it 'yields nothing if backward range' do
      range = described_class.new('c', 'a')

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing if empty range' do
      range = described_class.new('a', 'a', true)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end
  end

  context 'Symbol ranges' do
    it 'iterates until #succ returns a value that equals self.end' do
      range = described_class.new(:a, :ab)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%i[a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab])
    end

    it "doesn't yield self.end if end is excluded" do
      range = described_class.new(:a, :c, true)
      range.each { |e| ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%i[a b])
    end

    it 'works with endless ranges' do
      range = described_class.new(:a, nil)
      range.each { |e| break if e > :c; ScratchPad << e }

      expect(ScratchPad.recorded).to eq(%i[a b c])
    end

    it 'yields nothing if backward range' do
      range = described_class.new(:c, :a)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing if empty range' do
      range = described_class.new(:a, :a, true)

      range.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end
  end

  describe 'finit range' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the range size when Numeric range' do
          range = described_class.new(1, 4)
          expect(range.each.size).to eq(range.size)

          range = described_class.new(4, 1)
          expect(range.each.size).to eq(range.size)

          range = described_class.new(1, Float::INFINITY)
          expect(range.each.size).to eq(range.size)
        end

        it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
          range = described_class.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))

          expect {
            range.each.size
          }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")
        end

        it 'size returns the range size when non-Numeric range' do
          range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
          expect(range.each.size).to eq(range.size)
        end
      end
    end
  end

  describe 'infinit range' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns range size' do
          range = described_class.new(1, nil)
          expect(range.each.size).to eq(range.size)

          range = described_class.new(RangeSpecs::WithSucc.new(1), nil)
          expect(range.each.size).to eq(range.size)
        end
      end
    end
  end
end
