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

RSpec.describe 'Range#%' do
  before do
    ScratchPad.record []
  end

  it 'iterates the elements of range with given step' do # rubocop:disable RSpec/RepeatedExample
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(6)
      ]
    )
  end

  it 'iterates by calling #+' do # rubocop:disable RSpec/RepeatedExample
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(6)
      ]
    )
  end

  it 'returns self' do
    range = Range.new(0, 6)
    expect(range.%(2) {}).to equal(range)
  end

  it "doesn't yield self.end if end excluded" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6), true)
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4)
      ]
    )
  end

  it 'iterates backward when range is backward and step is decreasing' do
    range = Range.new(RangeSpecs::WithPlus.new(6), RangeSpecs::WithPlus.new(0))
    step = RangeSpecs::Step.new(-2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(6),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(0)
      ]
    )
  end

  it 'yields nothing when range is forward and step is decreasing' do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(-2)
    range.%(step) { |e| ScratchPad << e; break if e.value < -6 }

    expect(ScratchPad.recorded).to eq([])
  end

  it 'yields nothing when range is backward and step is increasing' do
    range = Range.new(RangeSpecs::WithPlus.new(6), RangeSpecs::WithPlus.new(0))
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e; break if e.value > 12 }

    expect(ScratchPad.recorded).to eq([])
  end

  it 'iterates indefinitely when endless range' do
    range = Range.new(RangeSpecs::WithPlus.new(0), nil)
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e; break if e.value > 4 }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(6)
      ]
    )
  end

  it 'raises ArgumentError when beginingless range with non-Numeric self.end' do
    range = Range.new(nil, RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)

    expect {
      range.%(step) {}
    }.to raise_error(ArgumentError, '#step iteration for beginless ranges is meaningless')
  end

  context 'given no block' do
    it 'returns an Enumerator if non-Numeric self.begin and self.end' do
      range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
      step = RangeSpecs::Step.new(2)
      e = range.%(step)

      expect(e).to be_an_instance_of(Enumerator)
      expect(e.to_a).to eq(
        [
          RangeSpecs::WithPlus.new(0),
          RangeSpecs::WithPlus.new(2),
          RangeSpecs::WithPlus.new(4),
          RangeSpecs::WithPlus.new(6)
        ]
      )
      e.each { |el| ScratchPad << el }
      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::WithPlus.new(0),
          RangeSpecs::WithPlus.new(2),
          RangeSpecs::WithPlus.new(4),
          RangeSpecs::WithPlus.new(6)
        ]
      )
    end

    it 'returns an Enumerator if Numeric self.begin and self.end but non-Numeric step' do
      step = RangeSpecs::Step.new(2)
      e = Range.new(0, 6).%(step)
      expect(e).to be_an_instance_of(Enumerator)
    end

    it 'iterates indefinitely when endless range and step is decreasing' do
      range = Range.new(RangeSpecs::WithPlus.new(0), nil)
      step = RangeSpecs::Step.new(-2)
      range.%(step) { |e| ScratchPad << e; break if e.value < -4 }

      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::WithPlus.new(0),
          RangeSpecs::WithPlus.new(-2),
          RangeSpecs::WithPlus.new(-4),
          RangeSpecs::WithPlus.new(-6)
        ]
      )
    end

    it 'raises ArgumentError when beginingless range' do
      range = Range.new(nil, RangeSpecs::WithPlus.new(6))
      step = RangeSpecs::Step.new(2)

      expect {
        range.%(step)
      }.to raise_error(ArgumentError, '#step for non-numeric beginless ranges is meaningless')
    end
  end

  context 'given no step' do
    it 'raises ArgumentError' do
      range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))

      expect {
        range.% {}
      }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
    end
  end

  context 'String boundaries and Integer step' do
    it 'iterates the elements of range by calling #succ called Integer step times' do
      Range.new('a', 'e').%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%w[a c e])
    end

    it "doesn't yield self.end if end excluded" do
      Range.new('a', 'e', true).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%w[a c])
    end

    it 'yields self.begin when step is 0' do
      Range.new('a', 'z').%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(['a'])
    end

    it 'yields nothing when step is 0 and range is backward' do
      Range.new('z', 'a').%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range and step is 0' do
      Range.new('a', 'a', true).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range and negative step' do
      Range.new('a', 'a', true).%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range' do
      Range.new('a', 'a', true).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when range is backward' do
      Range.new('b', 'a').%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when range is backward and step is negative' do
      Range.new('e', 'a').%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields self.begin when range is forward and step is negative' do
      Range.new('a', 'e').%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(['a'])
    end

    it 'yields nothing when range is backward and step is positive' do
      Range.new('e', 'a').%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'iterates indefinitely when endless range' do
      range = Range.new('a', nil)
      range.%(2) { |e| ScratchPad << e; break if e > 'c' }

      expect(ScratchPad.recorded).to eq(%w[a c e])
    end

    it 'iterates indefinitely when endless range and step is negative' do
      skip "`Range.new('a', nil).%(-2)` just hangs"

      range = Range.new('a', nil)
      range.%(-2) { |e| ScratchPad << e; break if e > 'c' }

      expect(ScratchPad.recorded).to eq(%w[a c e])
    end

    it 'raises ArgumentError when beginingless range' do
      range = Range.new(nil, 'e')

      expect {
        range.%(2) {}
      }.to raise_error(ArgumentError, '#step iteration for beginless ranges is meaningless')
    end

    context 'given no block' do
      it 'returns an Enumerator' do
        range = Range.new('a', 'e')
        e = range.%(2)

        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq(%w[a c e])
        e.each { |el| ScratchPad << el }
        expect(ScratchPad.recorded).to eq(%w[a c e])
      end

      it 'raises ArgumentError when beginingless range with non-Numeric self.end' do
        range = Range.new(nil, 'e')

        expect {
          range.%(2)
        }.to raise_error(ArgumentError, '#step for non-numeric beginless ranges is meaningless')
      end
    end

    context 'given no step' do
      it 'raises ArgumentError' do
        range = Range.new('a', 'c')

        expect {
          range.% {}
        }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end

    it 'handles a range as a range of Strings if non-String self.begin responds to #to_str' do
      a = RangeSpecs::WithToStr.new('a')
      range = Range.new(a, 'e')

      range.%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%w[a c e])
    end
  end

  context 'Symbol boundaries and Integer step' do
    it 'iterates the elements of range by calling #succ called Integer step times' do
      Range.new(:a, :e).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%i[a c e])
    end

    it "doesn't yield self.end if end excluded" do
      Range.new(:a, :e, true).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(%i[a c])
    end

    it 'yields self.begin when step is 0' do
      Range.new(:a, :z).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a])
    end

    it 'yields nothing when step is 0 and range is backward' do
      Range.new(:z, :a).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range and step is 0' do
      Range.new(:a, :a, true).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range and negative step' do
      Range.new(:a, :a, true).%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range' do
      Range.new(:a, :a, true).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when range is backward' do
      Range.new(:b, :a).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when range is backward and step is negative' do
      Range.new(:e, :a).%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields self.begin when range is forward and step is negative' do
      Range.new(:a, :e).%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a])
    end

    it 'yields nothing when range is backward and step is positive' do
      Range.new(:e, :a).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'iterates indefinitely when endless range' do
      range = Range.new(:a, nil)
      range.%(2) { |e| ScratchPad << e; break if e > :c }

      expect(ScratchPad.recorded).to eq(%i[a c e])
    end

    it 'iterates indefinitely when endless range and step is negative' do
      skip '`Range.new(:a, nil).%(-2)` just hangs'

      range = Range.new(:a, nil)
      range.%(-2) { |e| ScratchPad << e; break if e > :c }

      expect(ScratchPad.recorded).to eq(%i[a c e])
    end

    it 'raises ArgumentError when beginingless range' do
      range = Range.new(nil, :e)

      expect {
        range.%(2) {}
      }.to raise_error(ArgumentError, '#step iteration for beginless ranges is meaningless')
    end

    context 'given no block' do
      it 'returns an Enumerator' do
        range = Range.new(:a, :e)
        e = range.%(2)

        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq(%i[a c e])
        e.each { |el| ScratchPad << el }
        expect(ScratchPad.recorded).to eq(%i[a c e])
      end

      it 'raises ArgumentError when beginingless range with non-Numeric self.end' do
        range = Range.new(nil, :e)

        expect {
          range.%(2)
        }.to raise_error(ArgumentError, '#step for non-numeric beginless ranges is meaningless')
      end
    end

    context 'given no step' do
      it 'raises ArgumentError' do
        range = Range.new(:a, :c)

        expect {
          range.% {}
        }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end
  end

  context 'Numeric boundaries' do
    it 'iterates the elements of range with given step' do # rubocop:disable RSpec/RepeatedExample
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      range.%(2) { |e| ScratchPad << e }

      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::Number.new(0),
          RangeSpecs::Number.new(2),
          RangeSpecs::Number.new(4),
          RangeSpecs::Number.new(6)
        ]
      )
    end

    it "doesn't yield self.end if end excluded" do # rubocop:disable RSpec/RepeatedExample
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      range.%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::Number.new(0),
          RangeSpecs::Number.new(2),
          RangeSpecs::Number.new(4),
          RangeSpecs::Number.new(6)
        ]
      )
    end

    it 'raises ArgumentError when step is 0' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))

      expect {
        range.%(0) {}
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it 'raises ArgumentError when step is 0 and range is backward' do
      range = Range.new(RangeSpecs::Number.new(6), RangeSpecs::Number.new(0))

      expect {
        range.%(0) {}
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it 'raises ArgumentError when empty range and step is 0' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0), true)
      range.%(-1) { |e| ScratchPad << e }

      expect {
        range.%(0) {}
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it 'yields nothing when negative step' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      range.%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range and negative step' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0), true)
      range.%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when empty range' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0), true)
      range.%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'iterates backward when range is backward and step is negative' do
      range = Range.new(RangeSpecs::Number.new(6), RangeSpecs::Number.new(0))
      range.%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::Number.new(6),
          RangeSpecs::Number.new(4),
          RangeSpecs::Number.new(2),
          RangeSpecs::Number.new(0)
        ]
      )
    end

    it 'yields nothing when range is forward and step is negative' do
      range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      range.%(-2) { |e| ScratchPad << e; break if e.value < -6 }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'yields nothing when range is backward and step is positive' do
      range = Range.new(RangeSpecs::Number.new(6), RangeSpecs::Number.new(0))
      range.%(2) { |e| ScratchPad << e; break if e.value > 12 }
      expect(ScratchPad.recorded).to eq([])
    end

    it 'iterates indefinitely when endless range' do
      range = Range.new(RangeSpecs::Number.new(0), nil)
      range.%(2) { |e| ScratchPad << e; break if e.value > 4 }
      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::Number.new(0),
          RangeSpecs::Number.new(2),
          RangeSpecs::Number.new(4),
          RangeSpecs::Number.new(6)
        ]
      )
    end

    it 'iterates indefinitely when endless range and step is negative' do
      range = Range.new(RangeSpecs::Number.new(0), nil)
      range.%(-2) { |e| ScratchPad << e; break if e.value < -4 }
      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::Number.new(0),
          RangeSpecs::Number.new(-2),
          RangeSpecs::Number.new(-4),
          RangeSpecs::Number.new(-6)
        ]
      )
    end

    it 'raises ArgumentError when beginingless range' do
      range = Range.new(nil, RangeSpecs::Number.new(6))

      expect {
        range.%(2) {}
      }.to raise_error(ArgumentError, '#step iteration for beginless ranges is meaningless')
    end

    it 'yields Float::Infinity indefinitely when self.begin is -Float::Infinity' do
      range = Range.new(-Float::INFINITY, 0.0)

      range.%(2) do |x|
        ScratchPad << x
        break if ScratchPad.recorded.size == 3
      end

      expect(ScratchPad.recorded).to eq([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])
    end

    it 'iterates indefinitely when self.end is Float::Infinity' do
      range = Range.new(0.0, Float::INFINITY)

      range.%(2) do |x|
        ScratchPad << x
        break if ScratchPad.recorded.size == 3
      end

      expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
    end

    it 'yields self.begin as Float if self.end is Float' do
      Range.new(0, 6.0).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0, 6.0])
    end

    it 'yields self.begin as Float if step is Float' do
      Range.new(0, 6).%(2.0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0, 6.0])
    end

    it "doesn't loose precision when Float range or Float step" do
      skip 'not trivial to save precision'

      Range.new(1.0, 6.4).%(1.8) { |x| ScratchPad << x }
      expect(ScratchPad.recorded).to eql([1.0, 2.8, 4.6, 6.4])

      ScratchPad.record []
      Range.new(1.0, 12.7).%(1.3) { |x| ScratchPad << x }
      expect(ScratchPad.recorded).to eql([1.0, 2.3, 3.6, 4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.7])
    end

    context 'given no block' do
      it 'returns an Enumerator::ArithmeticSequence if Numeric self.begin, self.end, and step' do
        skip 'there is no way to instantiate ArithmeticSequence class manually'

        range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
        e = range.%(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)

        # use Integer boundaries intead of RangeSpecs::Number because
        # ArithmeticSequence#each expects a boundary value to implement #- and #/
        # that aren't implemented in RangeSpecs::Number for simplicity
        range = Range.new(0, 6)
        e = range.%(2)
        expect(e.to_a).to eq([0, 2, 4, 6])
        e.each { |el| ScratchPad << el }
        expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
      end

      it 'returns an Enumerator::ArithmeticSequence if beginingless range and Numeric self.end and step' do
        skip 'there is no way to instantiate ArithmeticSequence class manually'

        range = Range.new(nil, RangeSpecs::Number.new(6))
        e = range.%(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
      end

      it 'returns an Enumerator::ArithmeticSequence if endless range and Numeric self.begin and step' do
        skip 'there is no way to instantiate ArithmeticSequence class manually'

        range = Range.new(RangeSpecs::Number.new(0), nil)
        e = range.%(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
      end

      it 'raises ArgumentError when step is 0' do
        range = Range.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))

        expect {
          range.%(0)
        }.to raise_error(ArgumentError, "step can't be 0")
      end
    end

    context 'given no step' do
      it 'raises ArgumentError' do
        range = Range.new(0, 6)

        expect {
          range.% {}
        }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end

    describe 'returned Enumerator' do
      describe '#size' do
        context 'non-Numeric' do
          it 'returns nil' do
            range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
            step = RangeSpecs::Step.new(2)
            expect(range.%(step).size).to be_nil
          end

          it 'returns nil with self.begin and self.end are String' do
            expect(Range.new('a', 'e').%('-').size).to be_nil
            expect(Range.new('a', 'e').%(1).size).to be_nil
          end

          it 'returns nil with self.begin and self.end are Symbol' do
            expect(Range.new(:a, :e).%(:-).size).to be_nil
            expect(Range.new(:a, :e).%(1).size).to be_nil
          end
        end

        context 'Numeric range' do
          it 'returns the ceil of range size divided by the number of steps' do
            expect(Range.new(1, 10).%(4).size).to eq(3)
            expect(Range.new(1, 10).%(3).size).to eq(4)
            expect(Range.new(1, 10).%(2).size).to eq(5)
            expect(Range.new(1, 10).%(1).size).to eq(10)
            expect(Range.new(-5, 5).%(2).size).to eq(6)
            expect(Range.new(1, 10, true).%(4).size).to eq(3)
            expect(Range.new(1, 10, true).%(3).size).to eq(3)
            expect(Range.new(1, 10, true).%(2).size).to eq(5)
            expect(Range.new(1, 10, true).%(1).size).to eq(9)
            expect(Range.new(-5, 5, true).%(2).size).to eq(5)
          end

          it 'returns 0 if range is backward' do
            expect(Range.new(6, 0).%(2).size).to eq(0)
          end

          it 'returns the ceil of range size divided by the number of steps if step is negative and range is backward' do
            expect(Range.new(1, -1).%(-1).size).to eq(3)
          end

          it 'returns 0 if step is negative and range is forward' do
            expect(Range.new(-1, 1).%(-1).size).to eq(0)
          end

          it 'returns 0 if range is empty' do
            expect(Range.new(1, 1, true).%(1).size).to eq(0)
          end

          it 'returns correct number of steps when Float range' do
            expect(Range.new(-1, 1.0).%(0.5).size).to eq(5)
            expect(Range.new(-1.0, 1.0, true).%(0.5).size).to eq(4)
          end

          it 'ignores self.end accurately if excluded end and Float range or Float step' do
            expect(Range.new(1.0, 6.4, true).%(1.8).size).to eq(3) # 1.0 + 3 * 1.8 => 6.4
          end
        end
      end
    end
  end
end
