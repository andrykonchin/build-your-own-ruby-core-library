require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#%" do
  before :each do
    ScratchPad.record []
  end

  it "iterates over the elements of range with given step" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(6)
      ])
  end

  it "iterates by calling #+" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(6)
      ])
  end

  it 'returns self' do
    range = Range.new(0, 6)
    expect(range.%(2) {}).to equal(range)
  end

  it "doesn't yield the right boundary if end excluded" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6), true)
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(0),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(4)
      ])
  end

  it "iterates backward when range is backward and step is decreasing" do
    range = Range.new(RangeSpecs::WithPlus.new(6), RangeSpecs::WithPlus.new(0))
    step = RangeSpecs::Step.new(-2)
    range.%(step) { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithPlus.new(6),
        RangeSpecs::WithPlus.new(4),
        RangeSpecs::WithPlus.new(2),
        RangeSpecs::WithPlus.new(0)
      ])
  end

  it "yields nothing when range is forward and step is decreasing" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(-2)
    range.%(step) { |e| ScratchPad << e; break if e.value < -6 }

    expect(ScratchPad.recorded).to eq([])
  end

  it "yields nothing when range is backward and step is increasing" do
    range = Range.new(RangeSpecs::WithPlus.new(6), RangeSpecs::WithPlus.new(0))
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e; break if e.value > 12 }

    expect(ScratchPad.recorded).to eq([])
  end

  it "iterates indefinitely when endless range" do
    range = Range.new(RangeSpecs::WithPlus.new(0), nil)
    step = RangeSpecs::Step.new(2)
    range.%(step) { |e| ScratchPad << e; break if e.value > 4 }

    expect(ScratchPad.recorded).to eq([
      RangeSpecs::WithPlus.new(0),
      RangeSpecs::WithPlus.new(2),
      RangeSpecs::WithPlus.new(4),
      RangeSpecs::WithPlus.new(6)
    ])
  end

  it "raises ArgumentError when beginingless range with non-Numeric end" do
    range = Range.new(nil, RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)

    expect {
      range.%(step) {}
    }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
  end

  context "given no block" do
    it 'returns an Enumerator if non-Numeric begin and end' do
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
        ])
      e.each { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(
        [
          RangeSpecs::WithPlus.new(0),
          RangeSpecs::WithPlus.new(2),
          RangeSpecs::WithPlus.new(4),
          RangeSpecs::WithPlus.new(6)
        ])
    end

    it 'returns an Enumerator if Numeric begin and end but non-Numeric step' do
      step = RangeSpecs::Step.new(2)
      e = Range.new(0, 6).%(step)
      expect(e).to be_an_instance_of(Enumerator)
    end

    it "raises ArgumentError when beginingless range with non-Numeric end" do
      range = Range.new(nil, RangeSpecs::WithPlus.new(6))
      step = RangeSpecs::Step.new(2)

      expect {
        range.%(step)
      }.to raise_error(ArgumentError, "#step for non-numeric beginless ranges is meaningless")
    end
  end

  context "given no step" do
    it "raises ArgumentError" do
      range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))

      expect {
        range.%() {}
      }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1)")
    end
  end

  context "String boundaries and Integer step" do
    it "iterates over the elements of range by calling #succ called Integer step times" do
      Range.new("a", "e").%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a", "c", "e"])
    end

    it "doesn't yield the right boundary if end excluded" do
      Range.new("a", "e", true).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a", "c"])
    end

    it "yields begin when step is 0" do
      Range.new("a", "z").%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a"])
    end

    it "yields nothing when step is 0 and range is backward" do
      Range.new("z", "a").%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and step is 0" do
      Range.new("a", "a", true).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and negative step" do
      Range.new("a", "a", true).%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range" do
      Range.new("a", "a", true).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward" do
      Range.new("b", "a").%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward and step is negative" do
      Range.new("e", "a").%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields begin when range is forward and step is negative" do
      Range.new("a", "e").%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a"])
    end

    it "yields nothing when range is backward and step is positive" do
      Range.new("e", "a").%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates indefinitely when endless range" do
      range = Range.new("a", nil)
      range.%(2) { |e| ScratchPad << e; break if e > "c" }

      expect(ScratchPad.recorded).to eq(["a", "c", "e"])
    end

    it "raises ArgumentError when beginingless range" do
      range = Range.new(nil, "e")

      expect {
        range.%(2) {}
      }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
    end

    context "given no block" do
      it 'returns an Enumerator' do
        range = Range.new("a", "e")
        e = range.%(2)

        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq(["a", "c", "e"])
        e.each { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq(["a", "c", "e"])
      end

      it "raises ArgumentError when beginingless range with non-Numeric end" do
        range = Range.new(nil, "e")

        expect {
          range.%(2)
        }.to raise_error(ArgumentError, "#step for non-numeric beginless ranges is meaningless")
      end
    end

    context "given no step" do
      it "raises ArgumentError" do
        range = Range.new("a", "c")

        expect {
          range.%() {}
        }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1)")
      end
    end

    it "handles a range as a range of Strings if non-String begin responds to #to_str" do
      a = RangeSpecs::WithToStr.new("a")
      range = Range.new(a, "e")

      range.%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a", "c", "e"])
    end
  end

  context "Symbol boundaries and Integer step" do
    it "iterates over the elements of range by calling #succ called Integer step times" do
      Range.new(:a, :e).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a, :c, :e])
    end

    it "doesn't yield the right boundary if end excluded" do
      Range.new(:a, :e, true).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a, :c])
    end

    it "yields begin when step is 0" do
      Range.new(:a, :z).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a])
    end

    it "yields nothing when step is 0 and range is backward" do
      Range.new(:z, :a).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and step is 0" do
      Range.new(:a, :a, true).%(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and negative step" do
      Range.new(:a, :a, true).%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range" do
      Range.new(:a, :a, true).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward" do
      Range.new(:b, :a).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward and step is negative" do
      Range.new(:e, :a).%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields begin when range is forward and step is negative" do
      Range.new(:a, :e).%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a])
    end

    it "yields nothing when range is backward and step is positive" do
      Range.new(:e, :a).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates indefinitely when endless range" do
      range = Range.new(:a, nil)
      range.%(2) { |e| ScratchPad << e; break if e > :c }

      expect(ScratchPad.recorded).to eq([:a, :c, :e])
    end

    it "raises ArgumentError when beginingless range" do
      range = Range.new(nil, :e)

      expect {
        range.%(2) { }
      }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
    end

    context "given no block" do
      it 'returns an Enumerator' do
        range = Range.new(:a, :e)
        e = range.%(2)

        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq([:a, :c, :e])
        e.each { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq([:a, :c, :e])
      end

      it "raises ArgumentError when beginingless range with non-Numeric end" do
        range = Range.new(nil, :e)

        expect {
          range.%(2)
        }.to raise_error(ArgumentError, "#step for non-numeric beginless ranges is meaningless")
      end
    end

    context "given no step" do
      it "raises ArgumentError" do
        range = Range.new(:a, :c)

        expect {
          range.%() {}
        }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1)")
      end
    end
  end

  context "Numeric boundaries" do
    it "iterates over the elements of range with given step" do
      Range.new(0, 6).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
    end

    it "doesn't yield the right boundary if end excluded" do
      Range.new(0, 6, true).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0, 2, 4])
    end

    it "raises ArgumentError when step is 0" do
      range = Range.new(0, 6)

      expect {
        range.%(0) { }
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it "raises ArgumentError when step is 0 and range is backward" do
      range = Range.new(6, 0)

      expect {
        range.%(0) { }
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it "raises ArgumentError  when empty range and step is 0" do
      range = Range.new(0, 0, true)

      expect {
        range.%(0) { }
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it "yields nothing when negative step" do
      Range.new(0, 6).%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and negative step" do
      Range.new(0, 0, true).%(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range" do
      Range.new(0, 0, true).%(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates backward when range is backward and step is negative" do
      Range.new(6, 0).%(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([6, 4, 2, 0])
    end

    it "yields nothing when range is forward and step is negative" do
      Range.new(0, 6).%(-2) { |e| ScratchPad << e; break if e < -6 }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward and step is positive" do
      Range.new(6, 0).%(2) { |e| ScratchPad << e; break if e > 12 }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates indefinitely when endless range" do
      Range.new(0, nil).%(2) { |e| ScratchPad << e; break if e > 4 }
      expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
    end

    it "raises ArgumentError when beginingless range" do
      range = Range.new(nil, 6)

      expect {
        range.%(2) {}
      }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
    end

    it "yields Float::Infinity indefinitely when begin is -Float::Infinity" do
      range = Range.new(-Float::INFINITY, 0.0)

      range.%(2) do |x|
        ScratchPad << x
        break if ScratchPad.recorded.size == 3
      end

      expect(ScratchPad.recorded).to eq([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])
    end

    it "iterates indefinitely when end is Float::Infinity" do
      range = Range.new(0.0, Float::INFINITY)

      range.%(2) do |x|
        ScratchPad << x
        break if ScratchPad.recorded.size == 3
      end

      expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
    end

    it "yields begin as Float if end is Float" do
      Range.new(0, 6.0).%(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0.0, 2.0, 4.0, 6.0])
    end

    it "yields begin as Float if step is Float" do
      Range.new(0, 6).%(2.0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0.0, 2.0, 4.0, 6.0])
    end

    context "given no block" do
      it 'returns an Enumerator::ArithmeticSequence if Numeric begin, end, and step' do
        e = Range.new(0, 6).%(2)

        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
        expect(e.to_a).to eq([0, 2, 4, 6])
        e.each { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
      end

      it 'returns an Enumerator::ArithmeticSequence if beginingless range and Numeric end and step' do
        e = Range.new(nil, 6).%(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
      end

      it 'returns an Enumerator::ArithmeticSequence if endless range and Numeric begin and step' do
        e = Range.new(0, nil).%(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
      end
    end

    context "given no step" do
      it "raises ArgumentError" do
        range = Range.new(0, 6)

        expect {
          range.%() {}
        }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1)")
      end
    end

    describe "returned Enumerator" do
      describe "#size" do
        context "non-Numeric" do
          it "returns nil" do
            range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
            step = RangeSpecs::Step.new(2)
            expect(range.%(step).size).to eq(nil)
          end

          it "returns nil with begin and end are String" do
            expect(Range.new("a", "e").%("-").size).to eq(nil)
            expect(Range.new("a", "e").%(1).size).to eq(nil)
          end

          it "returns nil with begin and end are String" do
            expect(Range.new(:a, :e).%(:"-").size).to eq(nil)
            expect(Range.new(:a, :e).%(1).size).to eq(nil)
          end
        end

        context "Numeric range" do
          it "returns the ceil of range size divided by the number of steps" do
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

          it "returns 0 if range is backward" do
            expect(Range.new(6, 0).%(2).size).to eq(0)
          end

          it "returns the ceil of range size divided by the number of steps if step is negative and range is backward" do
            expect(Range.new(1, -1).%(-1).size).to eq(3)
          end

          it "returns 0 if step is negative and range is forward" do
            expect(Range.new(-1, 1).%(-1).size).to eq(0)
          end

          it "returns 0 if range is empty" do
            expect(Range.new(1, 1, true).%(1).size).to eq(0)
          end

          it "returns correct number of steps when Float range" do
            expect(Range.new(-1, 1.0        ).%(0.5).size).to eq(5)
            expect(Range.new(-1.0, 1.0, true).%(0.5).size).to eq(4)
          end
        end
      end
    end
  end
end
