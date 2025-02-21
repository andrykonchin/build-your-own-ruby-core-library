require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#step" do
  before :each do
    ScratchPad.record []
  end

  it "iterates over the elements of range with given step" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
    step = RangeSpecs::Step.new(2)
    range.step(step) { |e| ScratchPad << e }

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
    range.step(step) { |e| ScratchPad << e }

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
    expect(range.step(2) {}).to equal(range)
  end

  it "doesn't yield the right boundary if end excluded" do
    range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6), true)
    step = RangeSpecs::Step.new(2)
    range.step(step) { |e| ScratchPad << e }

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
    range.step(step) { |e| ScratchPad << e }

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
    range.step(step) { |e| ScratchPad << e; break if e.value < -6 }

    expect(ScratchPad.recorded).to eq([])
  end

  it "yields nothing when range is backward and step is increasing" do
    range = Range.new(RangeSpecs::WithPlus.new(6), RangeSpecs::WithPlus.new(0))
    step = RangeSpecs::Step.new(2)
    range.step(step) { |e| ScratchPad << e; break if e.value > 12 }

    expect(ScratchPad.recorded).to eq([])
  end

  it "iterates indefinitely when endless range" do
    range = Range.new(RangeSpecs::WithPlus.new(0), nil)
    step = RangeSpecs::Step.new(2)
    range.step(step) { |e| ScratchPad << e; break if e.value > 4 }

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
      range.step(step) {}
    }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
  end

  context "given no block" do
    it 'returns an Enumerator if non-Numeric begin and end' do
      range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
      step = RangeSpecs::Step.new(2)
      e = range.step(step)

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
      e = Range.new(0, 6).step(step)
      expect(e).to be_an_instance_of(Enumerator)
    end

    it "raises ArgumentError when beginingless range with non-Numeric end" do
      range = Range.new(nil, RangeSpecs::WithPlus.new(6))
      step = RangeSpecs::Step.new(2)

      expect {
        range.step(step)
      }.to raise_error(ArgumentError, "#step for non-numeric beginless ranges is meaningless")
    end
  end

  context "given no step" do
    it "raises ArgumentError for ranges with non-Numeric begin" do
      range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))

      expect {
        range.step {}
      }.to raise_error(ArgumentError, "step is required for non-numeric ranges")
    end
  end

  context "String boundaries and Integer step" do
    it "iterates over the elements of range by calling #succ called Integer step times" do
      Range.new("a", "e").step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a", "c", "e"])
    end

    it "doesn't yield the right boundary if end excluded" do
      Range.new("a", "e", true).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a", "c"])
    end

    it "yields begin when step is 0" do
      Range.new("a", "z").step(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a"])
    end

    it "yields nothing when step is 0 and range is backward" do
      Range.new("z", "a").step(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and step is 0" do
      Range.new("a", "a", true).step(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and negative step" do
      Range.new("a", "a", true).step(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range" do
      Range.new("a", "a", true).step(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward" do
      Range.new("b", "a").step(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward and step is negative" do
      Range.new("e", "a").step(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields begin when range is forward and step is negative" do
      Range.new("a", "e").step(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a"])
    end

    it "yields nothing when range is backward and step is positive" do
      Range.new("e", "a").step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates indefinitely when endless range" do
      range = Range.new("a", nil)
      range.step(2) { |e| ScratchPad << e; break if e > "c" }

      expect(ScratchPad.recorded).to eq(["a", "c", "e"])
    end

    it "raises ArgumentError when beginingless range" do
      range = Range.new(nil, "e")

      expect {
        range.step(2) {}
      }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
    end

    context "given no block" do
      it 'returns an Enumerator' do
        range = Range.new("a", "e")
        e = range.step(2)

        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq(["a", "c", "e"])
        e.each { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq(["a", "c", "e"])
      end

      it "raises ArgumentError when beginingless range with non-Numeric end" do
        range = Range.new(nil, "e")

        expect {
          range.step(2)
        }.to raise_error(ArgumentError, "#step for non-numeric beginless ranges is meaningless")
      end
    end

    context "given no step" do
      it "yields String values incremented by #succ" do
        range = Range.new("a", "c")
        range.step { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq(["a", "b", "c"])
      end
    end

    it "handles a range as a range of Strings if non-String begin responds to #to_str" do
      a = RangeSpecs::WithToStr.new("a")
      range = Range.new(a, "e")

      range.step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq(["a", "c", "e"])
    end
  end

  context "Symbol boundaries and Integer step" do
    it "iterates over the elements of range by calling #succ called Integer step times" do
      Range.new(:a, :e).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a, :c, :e])
    end

    it "doesn't yield the right boundary if end excluded" do
      Range.new(:a, :e, true).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a, :c])
    end

    it "yields begin when step is 0" do
      Range.new(:a, :z).step(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a])
    end

    it "yields nothing when step is 0 and range is backward" do
      Range.new(:z, :a).step(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and step is 0" do
      Range.new(:a, :a, true).step(0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and negative step" do
      Range.new(:a, :a, true).step(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range" do
      Range.new(:a, :a, true).step(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward" do
      Range.new(:b, :a).step(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward and step is negative" do
      Range.new(:e, :a).step(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields begin when range is forward and step is negative" do
      Range.new(:a, :e).step(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([:a])
    end

    it "yields nothing when range is backward and step is positive" do
      Range.new(:e, :a).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates indefinitely when endless range" do
      range = Range.new(:a, nil)
      range.step(2) { |e| ScratchPad << e; break if e > :c }

      expect(ScratchPad.recorded).to eq([:a, :c, :e])
    end

    it "raises ArgumentError when beginingless range" do
      range = Range.new(nil, :e)

      expect {
        range.step(2) { }
      }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
    end

    context "given no block" do
      it 'returns an Enumerator' do
        range = Range.new(:a, :e)
        e = range.step(2)

        expect(e).to be_an_instance_of(Enumerator)
        expect(e.to_a).to eq([:a, :c, :e])
        e.each { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq([:a, :c, :e])
      end

      it "raises ArgumentError when beginingless range with non-Numeric end" do
        range = Range.new(nil, :e)

        expect {
          range.step(2)
        }.to raise_error(ArgumentError, "#step for non-numeric beginless ranges is meaningless")
      end
    end

    context "given no step" do
      it "yields Symbol values incremented by #succ" do
        range = Range.new(:a, :c)
        range.step { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq([:a, :b, :c])
      end
    end
  end

  context "Numeric boundaries" do
    it "iterates over the elements of range with given step" do
      Range.new(0, 6).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
    end

    it "doesn't yield the right boundary if end excluded" do
      Range.new(0, 6, true).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0, 2, 4])
    end

    it "raises ArgumentError when step is 0" do
      range = Range.new(0, 6)

      expect {
        range.step(0) { }
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it "raises ArgumentError when step is 0 and range is backward" do
      range = Range.new(6, 0)

      expect {
        range.step(0) { }
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it "raises ArgumentError  when empty range and step is 0" do
      range = Range.new(0, 0, true)

      expect {
        range.step(0) { }
      }.to raise_error(ArgumentError, "step can't be 0")
    end

    it "yields nothing when negative step" do
      Range.new(0, 6).step(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range and negative step" do
      Range.new(0, 0, true).step(-1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when empty range" do
      Range.new(0, 0, true).step(1) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates backward when range is backward and step is negative" do
      Range.new(6, 0).step(-2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([6, 4, 2, 0])
    end

    it "yields nothing when range is forward and step is negative" do
      Range.new(0, 6).step(-2) { |e| ScratchPad << e; break if e < -6 }
      expect(ScratchPad.recorded).to eq([])
    end

    it "yields nothing when range is backward and step is positive" do
      Range.new(6, 0).step(2) { |e| ScratchPad << e; break if e > 12 }
      expect(ScratchPad.recorded).to eq([])
    end

    it "iterates indefinitely when endless range" do
      Range.new(0, nil).step(2) { |e| ScratchPad << e; break if e > 4 }
      expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
    end

    it "raises ArgumentError when beginingless range" do
      range = Range.new(nil, 6)

      expect {
        range.step(2) {}
      }.to raise_error(ArgumentError, "#step iteration for beginless ranges is meaningless")
    end

    it "yields Float::Infinity indefinitely when begin is -Float::Infinity" do
      range = Range.new(-Float::INFINITY, 0.0)

      range.step(2) do |x|
        ScratchPad << x
        break if ScratchPad.recorded.size == 3
      end

      expect(ScratchPad.recorded).to eq([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])
    end

    it "iterates indefinitely when end is Float::Infinity" do
      range = Range.new(0.0, Float::INFINITY)

      range.step(2) do |x|
        ScratchPad << x
        break if ScratchPad.recorded.size == 3
      end

      expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
    end

    it "yields begin as Float if end is Float" do
      Range.new(0, 6.0).step(2) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0.0, 2.0, 4.0, 6.0])
    end

    it "yields begin as Float if step is Float" do
      Range.new(0, 6).step(2.0) { |e| ScratchPad << e }
      expect(ScratchPad.recorded).to eq([0.0, 2.0, 4.0, 6.0])
    end

    context "given no block" do
      it 'returns an Enumerator::ArithmeticSequence if Numeric begin, end, and step' do
        e = Range.new(0, 6).step(2)

        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
        expect(e.to_a).to eq([0, 2, 4, 6])
        e.each { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq([0, 2, 4, 6])
      end

      it 'returns an Enumerator::ArithmeticSequence if beginingless range and Numeric end and step' do
        e = Range.new(nil, 6).step(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
      end

      it 'returns an Enumerator::ArithmeticSequence if endless range and Numeric begin and step' do
        e = Range.new(0, nil).step(2)
        expect(e).to be_an_instance_of(Enumerator::ArithmeticSequence)
      end
    end

    context "given no step" do
      it "yields Numeric values incremented by 1" do
        Range.new(0, 6).step { |e| ScratchPad << e }
        expect(ScratchPad.recorded).to eq([0, 1, 2, 3, 4, 5, 6])
      end
    end

    describe "returned Enumerator" do
      describe "#size" do
        context "non-Numeric" do
          it "returns nil" do
            range = Range.new(RangeSpecs::WithPlus.new(0), RangeSpecs::WithPlus.new(6))
            step = RangeSpecs::Step.new(2)
            expect(range.step(step).size).to eq(nil)
          end

          it "returns nil with begin and end are String" do
            expect(Range.new("a", "e").step("-").size).to eq(nil)
            expect(Range.new("a", "e").step(1).size).to eq(nil)
          end

          it "returns nil with begin and end are String" do
            expect(Range.new(:a, :e).step(:"-").size).to eq(nil)
            expect(Range.new(:a, :e).step(1).size).to eq(nil)
          end
        end

        context "Numeric range" do
          it "returns the ceil of range size divided by the number of steps" do
            expect(Range.new(1, 10).step(4).size).to eq(3)
            expect(Range.new(1, 10).step(3).size).to eq(4)
            expect(Range.new(1, 10).step(2).size).to eq(5)
            expect(Range.new(1, 10).step(1).size).to eq(10)
            expect(Range.new(-5, 5).step(2).size).to eq(6)
            expect(Range.new(1, 10, true).step(4).size).to eq(3)
            expect(Range.new(1, 10, true).step(3).size).to eq(3)
            expect(Range.new(1, 10, true).step(2).size).to eq(5)
            expect(Range.new(1, 10, true).step(1).size).to eq(9)
            expect(Range.new(-5, 5, true).step(2).size).to eq(5)
          end

          it "returns 0 if range is backward" do
            expect(Range.new(6, 0).step(2).size).to eq(0)
          end

          it "returns the ceil of range size divided by the number of steps if step is negative and range is backward" do
            expect(Range.new(1, -1).step(-1).size).to eq(3)
          end

          it "returns 0 if step is negative and range is forward" do
            expect(Range.new(-1, 1).step(-1).size).to eq(0)
          end

          it "returns 0 if range is empty" do
            expect(Range.new(1, 1, true).step(1).size).to eq(0)
          end

          it "returns correct number of steps when Float range" do
            expect(Range.new(-1, 1.0        ).step(0.5).size).to eq(5)
            expect(Range.new(-1.0, 1.0, true).step(0.5).size).to eq(4)
          end

          it "returns the range size when given no step" do
            expect(Range.new(-2, 2      ).step.size).to eq(5)
            expect(Range.new(-2, 2, true).step.size).to eq(4)
          end
        end
      end
    end
  end
end

# TODO: remove them when solition is ready
# Old specs
RSpec.describe "Range#step" do
  before :each do
    ScratchPad.record []
  end

  it "returns self" do
    r = Range.new(1, 2)
    expect(r.step { }).to equal(r)
  end

  it "calls #coerce to coerce step to an Integer" do
    obj = double("Range#step")
    expect(obj).to receive(:coerce).at_least(:once).and_return([1, 2])

    Range.new(1, 3).step(obj) { |x| ScratchPad << x }
    expect(ScratchPad.recorded).to eql([1, 3])
  end

  it "raises a TypeError if step does not respond to #coerce" do
    obj = double("Range#step non-coercible")

    expect { Range.new(1, 2).step(obj) { } }.to raise_error(TypeError)
  end

  it "raises an ArgumentError if step is 0" do
    expect { Range.new(-1, 1).step(0) { |x| x } }.to raise_error(ArgumentError)
  end

  it "raises an ArgumentError if step is 0.0" do
    expect { Range.new(-1, 1).step(0.0) { |x| x } }.to raise_error(ArgumentError)
  end

  it "does not raise an ArgumentError if step is 0 for non-numeric ranges" do
    t = Time.utc(2023, 2, 24)
    expect { Range.new(t, t+1).step(0) { break } }.not_to raise_error
  end

  describe "with inclusive end" do
    describe "and Integer values" do
      it "yields Integer values incremented by 1 and less than or equal to end when not passed a step" do
        Range.new(-2, 2).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1, 2])
      end

      it "yields Integer values incremented by an Integer step" do
        Range.new(-5, 5).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3, 5])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-2, 2).step(1.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])
      end

      it "does not iterate if step is negative for forward range" do
        Range.new(-1, 1).step(-1) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([])
      end

      it "iterates backward if step is negative for backward range" do
        Range.new(1, -1).step(-1) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1, 0, -1])
      end
    end

    describe "and Float values" do
      it "yields Float values incremented by 1 and less than or equal to end when not passed a step" do
        Range.new(-2.0, 2.0).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0, 2.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5.0, 5.0).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0, 5.0])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-1.0, 1.0).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5, 1.0])
      end

      it "returns Float values of 'step * n + begin <= end'" do
        Range.new(1.0, 6.4).step(1.8) { |x| ScratchPad << x }
        Range.new(1.0, 12.7).step(1.3) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1.0, 2.8, 4.6, 6.4, 1.0, 2.3, 3.6,
                                       4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.7])
      end

      it "handles infinite values at either end" do
        Range.new(-Float::INFINITY, 0.0).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])

        ScratchPad.record []
        Range.new(0.0, Float::INFINITY).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
      end
    end

    describe "and Integer, Float values" do
      it "yields Float values incremented by 1 and less than or equal to end when not passed a step" do
        Range.new(-2, 2.0).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0, 2.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5, 5.0).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0, 5.0])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-1, 1.0).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5, 1.0])
      end
    end

    describe "and Float, Integer values" do
      it "yields Float values incremented by 1 and less than or equal to end when not passed a step" do
        Range.new(-2.0, 2).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0, 2.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5.0, 5).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0, 5.0])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-1.0, 1).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5, 1.0])
      end
    end

    describe "and String values" do
      it "yields String values incremented by #succ and less than or equal to end when not passed a step" do
        Range.new("A", "E").step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "B", "C", "D", "E"])
      end

      it "yields String values incremented by #succ called Integer step times" do
        Range.new("A", "G").step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "C", "E", "G"])
      end

      it "raises a TypeError when passed a Float step" do
        expect { Range.new("A", "G").step(2.0) { } }.to raise_error(TypeError)
      end

      it "yields String values adjusted by step and less than or equal to end" do
        Range.new("A", "AAA").step("A") { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA", "AAA"])
      end

      it "raises a TypeError when passed an incompatible type step" do
        expect { Range.new("A", "G").step([]) { } }.to raise_error(TypeError)
      end

      it "calls #+ on begin and each element returned by #+" do
        start = double("Range#step String start")
        stop = double("Range#step String stop")

        mid1 = double("Range#step String mid1")
        mid2 = double("Range#step String mid2")

        step = double("Range#step String step")

        # Deciding on the direction of iteration
        expect(start).to receive(:<=>).with(stop).at_least(:twice).and_return(-1)
        # Deciding whether the step moves iteration in the right direction
        expect(start).to receive(:<=>).with(mid1).and_return(-1)
        # Iteration 1
        expect(start).to receive(:+).at_least(:once).with(step).and_return(mid1)
        # Iteration 2
        expect(mid1).to receive(:<=>).with(stop).and_return(-1)
        expect(mid1).to receive(:+).with(step).and_return(mid2)
        # Iteration 3
        expect(mid2).to receive(:<=>).with(stop).and_return(0)

        Range.new(start, stop).step(step) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq([start, mid1, mid2])
      end

      it "iterates backward if the step is decreasing values, and the range is backward" do
        start = double("Range#step String start")
        stop = double("Range#step String stop")

        mid1 = double("Range#step String mid1")
        mid2 = double("Range#step String mid2")

        step = double("Range#step String step")

        # Deciding on the direction of iteration
        expect(start).to receive(:<=>).with(stop).at_least(:twice).and_return(1)
        # Deciding whether the step moves iteration in the right direction
        expect(start).to receive(:<=>).with(mid1).and_return(1)
        # Iteration 1
        expect(start).to receive(:+).at_least(:once).with(step).and_return(mid1)
        # Iteration 2
        expect(mid1).to receive(:<=>).with(stop).and_return(1)
        expect(mid1).to receive(:+).with(step).and_return(mid2)
        # Iteration 3
        expect(mid2).to receive(:<=>).with(stop).and_return(0)

        Range.new(start, stop).step(step) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq([start, mid1, mid2])
      end

      it "does no iteration of the direction of the range and of the step don't match" do
        start = double("Range#step String start")
        stop = double("Range#step String stop")

        mid1 = double("Range#step String mid1")
        mid2 = double("Range#step String mid2")

        step = double("Range#step String step")

        # Deciding on the direction of iteration: stop > start
        expect(start).to receive(:<=>).with(stop).at_least(:twice).and_return(1)
        # Deciding whether the step moves iteration in the right direction
        # start + step < start, the direction is opposite to the range's
        expect(start).to receive(:+).with(step).and_return(mid1)
        expect(start).to receive(:<=>).with(mid1).and_return(-1)

        Range.new(start, stop).step(step) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq([])
      end
    end
  end

  describe "with exclusive end" do
    describe "and Integer values" do
      it "yields Integer values incremented by 1 and less than end when not passed a step" do
        Range.new(-2, 2, true).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1])
      end

      it "yields Integer values incremented by an Integer step" do
        Range.new(-5, 5, true).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-2, 2, true).step(1.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])
      end
    end

    describe "and Float values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        Range.new(-2.0, 2.0, true).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5.0, 5.0, true).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-1.0, 1.0, true).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end

      it "returns Float values of 'step * n + begin < end'" do
        Range.new(1.0, 6.4, true).step(1.8) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1.0, 2.8, 4.6])
      end

      it "correctly handles values near the upper limit" do # https://bugs.ruby-lang.org/issues/16612
        Range.new(1.0, 55.6, true).step(18.2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1.0, 19.2, 37.4, 55.599999999999994])

        expect(Range.new(1.0, 55.6, true).step(18.2).size).to eq(4)
      end

      it "handles infinite values at either end" do
        Range.new(-Float::INFINITY, 0.0, true).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])

        ScratchPad.record []
        Range.new(0.0, Float::INFINITY, true).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
      end
    end

    describe "and Integer, Float values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        Range.new(-2, 2.0, true).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5, 5.0, true).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields an Float and then Float values incremented by a Float step" do
        Range.new(-1, 1.0, true).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end
    end

    describe "and Float, Integer values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        Range.new(-2.0, 2, true).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5.0, 5, true).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-1.0, 1, true).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end
    end

    describe "and String values" do
      it "yields String values adjusted by step and less than or equal to end" do
        Range.new("A", "AAA", true).step("A") { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA"])
      end

      it "raises a TypeError when passed an incompatible type step" do
        expect { Range.new("A", "G").step([]) { } }.to raise_error(TypeError)
      end
    end
  end

  describe "with an endless range" do
    describe "and Integer values" do
      it "yield Integer values incremented by 1 when not passed a step" do
        Range.new(-2, nil).step { |x| break if x > 2; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1, 2])

        ScratchPad.record []
        Range.new(-2, nil, true).step { |x| break if x > 2; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1, 2])
      end

      it "yields Integer values incremented by an Integer step" do
        Range.new(-5, nil).step(2) { |x| break if x > 3; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3])

        ScratchPad.record []
        Range.new(-5, nil, true).step(2) { |x| break if x > 3; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-2, nil).step(1.5) { |x| break if x > 1.0; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])

        ScratchPad.record []
        Range.new(-2, nil).step(1.5) { |x| break if x > 1.0; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])
      end
    end

    describe "and Float values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        Range.new(-2.0, nil).step { |x| break if x > 1.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])

        ScratchPad.record []
        Range.new(-2.0, nil, true).step { |x| break if x > 1.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        Range.new(-5.0, nil).step(2) { |x| break if x > 3.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])

        ScratchPad.record []
        Range.new(-5.0, nil, true).step(2) { |x| break if x > 3.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields Float values incremented by a Float step" do
        Range.new(-1.0, nil).step(0.5) { |x| break if x > 0.6; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])

        ScratchPad.record []
        Range.new(-1.0, nil, true).step(0.5) { |x| break if x > 0.6; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end

      it "handles infinite values at the start" do
        Range.new(-Float::INFINITY, nil).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])

        ScratchPad.record []
        Range.new(-Float::INFINITY, nil, true).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])
      end
    end

    describe "and String values" do
      it "yields String values incremented by #succ and less than or equal to end when not passed a step" do
        Range.new('A', nil).step { |x| break if x > "D"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "B", "C", "D"])

        ScratchPad.record []
        Range.new('A', nil, true).step { |x| break if x > "D"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "B", "C", "D"])
      end

      it "yields String values incremented by #succ called Integer step times" do
        Range.new('A', nil).step(2) { |x| break if x > "F"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "C", "E"])

        ScratchPad.record []
        Range.new('A', nil, true).step(2) { |x| break if x > "F"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "C", "E"])
      end

      it "raises a TypeError when passed a Float step" do
        expect { Range.new('A', nil).step(2.0) { } }.to raise_error(TypeError)
        expect { Range.new('A', nil, true).step(2.0) { } }.to raise_error(TypeError)
      end

      it "yields String values adjusted by step" do
        Range.new('A', nil).step("A") { |x| break if x > "AAA"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA", "AAA"])

        ScratchPad.record []
        Range.new('A', nil, true).step("A") { |x| break if x > "AAA"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA", "AAA"])
      end

      it "raises a TypeError when passed an incompatible type step" do
        expect { Range.new('A', nil).step([]) { } }.to raise_error(TypeError)
        expect { Range.new('A', nil, true).step([]) { } }.to raise_error(TypeError)
      end
    end
  end

  describe "given no block" do
    it "raises an ArgumentError if step is 0" do
      expect { Range.new(-1, 1).step(0) }.to raise_error(ArgumentError)
    end

    describe "returned Enumerator" do
      describe "size" do
        it "does not raise if step is incompatible" do
          obj = double("Range#step non-integer")
          expect { Range.new(1, 2).step(obj) }.not_to raise_error
        end

        it "returns the ceil of range size divided by the number of steps" do
          expect(Range.new(1, 10).step(4).size).to eq(3)
          expect(Range.new(1, 10).step(3).size).to eq(4)
          expect(Range.new(1, 10).step(2).size).to eq(5)
          expect(Range.new(1, 10).step(1).size).to eq(10)
          expect(Range.new(-5, 5).step(2).size).to eq(6)
          expect(Range.new(1, 10, true).step(4).size).to eq(3)
          expect(Range.new(1, 10, true).step(3).size).to eq(3)
          expect(Range.new(1, 10, true).step(2).size).to eq(5)
          expect(Range.new(1, 10, true).step(1).size).to eq(9)
          expect(Range.new(-5, 5, true).step(2).size).to eq(5)
        end

        it "returns the ceil of range size divided by the number of steps even if step is negative" do
          expect(Range.new(-1, 1).step(-1).size).to eq(0)
          expect(Range.new(1, -1).step(-1).size).to eq(3)
        end

        it "returns the correct number of steps when one of the arguments is a float" do
          expect(Range.new(-1, 1.0).step(0.5).size).to eq(5)
          expect(Range.new(-1.0, 1.0, true).step(0.5).size).to eq(4)
        end

        it "returns the range size when there's no step_size" do
          expect(Range.new(-2, 2).step.size).to eq(5)
          expect(Range.new(-2.0, 2.0).step.size).to eq(5)
          expect(Range.new(-2, 2.0).step.size).to eq(5)
          expect(Range.new(-2.0, 2).step.size).to eq(5)
          expect(Range.new(1.0, 6.4).step(1.8).size).to eq(4)
          expect(Range.new(1.0, 12.7).step(1.3).size).to eq(10)
          expect(Range.new(-2, 2, true).step.size).to eq(4)
          expect(Range.new(-2.0, 2.0, true).step.size).to eq(4)
          expect(Range.new(-2, 2.0, true).step.size).to eq(4)
          expect(Range.new(-2.0, 2, true).step.size).to eq(4)
          expect(Range.new(1.0, 6.4, true).step(1.8).size).to eq(3)
        end

        it "returns nil with begin and end are String" do
          expect(Range.new("A", "E").step("A").size).to eq(nil)
          expect(Range.new("A", "E", true).step("A").size).to eq(nil)
        end

        it "return nil and not raises a TypeError if the first element is not of compatible type" do
          obj = double("Range#step non-comparable")
          expect(obj).to receive(:<=>).with(obj).and_return(1)
          enum = Range.new(obj, obj).step(obj)
          expect { enum.size }.not_to raise_error
          expect(enum.size).to eq(nil)
        end
      end

      # We use .take below to ensure the enumerator works
      # because that's an Enumerable method and so it uses the Enumerator behavior
      # not just a method overridden in Enumerator::ArithmeticSequence.
      describe "type" do
        context "when both begin and end are numerics" do
          it "returns an instance of Enumerator::ArithmeticSequence" do
            expect(Range.new(1, 10).step.class).to eq(Enumerator::ArithmeticSequence)
            expect(Range.new(1, 10).step(3).take(4)).to eq([1, 4, 7, 10])
          end
        end

        context "when begin is not defined and end is numeric" do
          it "returns an instance of Enumerator::ArithmeticSequence" do
            expect(Range.new(nil, 10).step.class).to eq(Enumerator::ArithmeticSequence)
          end
        end

        context "when range is endless" do
          it "returns an instance of Enumerator::ArithmeticSequence when begin is numeric" do
            expect(Range.new(1, nil).step.class).to eq(Enumerator::ArithmeticSequence)
            expect(Range.new(1, nil).step(2).take(3)).to eq([1, 3, 5])
          end

          it "returns an instance of Enumerator when begin is not numeric" do
            expect(Range.new("a", nil).step("a").class).to eq(Enumerator)
            expect(Range.new("a", nil).step("a").take(3)).to eq(%w[a aa aaa])
          end
        end

        context "when range is beginless and endless" do
          it "raises an ArgumentError" do
            expect { Range.new(nil, nil).step(1) }.to raise_error(ArgumentError)
          end
        end

        context "when begin and end are not numerics" do
          it "returns an instance of Enumerator" do
            expect(Range.new("a", "z").step("a").class).to eq(Enumerator)
            expect(Range.new("a", "z").step("a").take(4)).to eq(%w[a aa aaa aaaa])
          end
        end
      end
    end
  end
end
