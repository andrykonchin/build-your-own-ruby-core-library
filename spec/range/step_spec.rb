require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#step" do
  before :each do
    ScratchPad.record []
  end

  it "returns self" do
    r = 1..2
    expect(r.step { }).to equal(r)
  end

  it "calls #coerce to coerce step to an Integer" do
    obj = double("Range#step")
    expect(obj).to receive(:coerce).at_least(:once).and_return([1, 2])

    (1..3).step(obj) { |x| ScratchPad << x }
    expect(ScratchPad.recorded).to eql([1, 3])
  end

  it "raises a TypeError if step does not respond to #coerce" do
    obj = double("Range#step non-coercible")

    expect { (1..2).step(obj) { } }.to raise_error(TypeError)
  end

  it "raises an ArgumentError if step is 0" do
    expect { (-1..1).step(0) { |x| x } }.to raise_error(ArgumentError)
  end

  it "raises an ArgumentError if step is 0.0" do
    expect { (-1..1).step(0.0) { |x| x } }.to raise_error(ArgumentError)
  end

  it "does not raise an ArgumentError if step is 0 for non-numeric ranges" do
    t = Time.utc(2023, 2, 24)
    expect { (t..t+1).step(0) { break } }.not_to raise_error
  end

  describe "with inclusive end" do
    describe "and Integer values" do
      it "yields Integer values incremented by 1 and less than or equal to end when not passed a step" do
        (-2..2).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1, 2])
      end

      it "yields Integer values incremented by an Integer step" do
        (-5..5).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3, 5])
      end

      it "yields Float values incremented by a Float step" do
        (-2..2).step(1.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])
      end

      it "does not iterate if step is negative for forward range" do
        (-1..1).step(-1) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([])
      end

      it "iterates backward if step is negative for backward range" do
        (1..-1).step(-1) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1, 0, -1])
      end
    end

    describe "and Float values" do
      it "yields Float values incremented by 1 and less than or equal to end when not passed a step" do
        (-2.0..2.0).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0, 2.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5.0..5.0).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0, 5.0])
      end

      it "yields Float values incremented by a Float step" do
        (-1.0..1.0).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5, 1.0])
      end

      it "returns Float values of 'step * n + begin <= end'" do
        (1.0..6.4).step(1.8) { |x| ScratchPad << x }
        (1.0..12.7).step(1.3) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1.0, 2.8, 4.6, 6.4, 1.0, 2.3, 3.6,
                                       4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.7])
      end

      it "handles infinite values at either end" do
        (-Float::INFINITY..0.0).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])

        ScratchPad.record []
        (0.0..Float::INFINITY).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
      end
    end

    describe "and Integer, Float values" do
      it "yields Float values incremented by 1 and less than or equal to end when not passed a step" do
        (-2..2.0).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0, 2.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5..5.0).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0, 5.0])
      end

      it "yields Float values incremented by a Float step" do
        (-1..1.0).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5, 1.0])
      end
    end

    describe "and Float, Integer values" do
      it "yields Float values incremented by 1 and less than or equal to end when not passed a step" do
        (-2.0..2).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0, 2.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5.0..5).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0, 5.0])
      end

      it "yields Float values incremented by a Float step" do
        (-1.0..1).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5, 1.0])
      end
    end

    describe "and String values" do
      it "yields String values incremented by #succ and less than or equal to end when not passed a step" do
        ("A".."E").step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "B", "C", "D", "E"])
      end

      it "yields String values incremented by #succ called Integer step times" do
        ("A".."G").step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "C", "E", "G"])
      end

      it "raises a TypeError when passed a Float step" do
        expect { ("A".."G").step(2.0) { } }.to raise_error(TypeError)
      end

      it "yields String values adjusted by step and less than or equal to end" do
        ("A".."AAA").step("A") { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA", "AAA"])
      end

      it "raises a TypeError when passed an incompatible type step" do
        expect { ("A".."G").step([]) { } }.to raise_error(TypeError)
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

        (start..stop).step(step) { |x| ScratchPad << x }
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

        (start..stop).step(step) { |x| ScratchPad << x }
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

        (start..stop).step(step) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq([])
      end
    end
  end

  describe "with exclusive end" do
    describe "and Integer values" do
      it "yields Integer values incremented by 1 and less than end when not passed a step" do
        (-2...2).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1])
      end

      it "yields Integer values incremented by an Integer step" do
        (-5...5).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3])
      end

      it "yields Float values incremented by a Float step" do
        (-2...2).step(1.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])
      end
    end

    describe "and Float values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        (-2.0...2.0).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5.0...5.0).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields Float values incremented by a Float step" do
        (-1.0...1.0).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end

      it "returns Float values of 'step * n + begin < end'" do
        (1.0...6.4).step(1.8) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1.0, 2.8, 4.6])
      end

      it "correctly handles values near the upper limit" do # https://bugs.ruby-lang.org/issues/16612
        (1.0...55.6).step(18.2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([1.0, 19.2, 37.4, 55.599999999999994])

        expect((1.0...55.6).step(18.2).size).to eq(4)
      end

      it "handles infinite values at either end" do
        (-Float::INFINITY...0.0).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])

        ScratchPad.record []
        (0.0...Float::INFINITY).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([0.0, 2.0, 4.0])
      end
    end

    describe "and Integer, Float values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        (-2...2.0).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5...5.0).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields an Float and then Float values incremented by a Float step" do
        (-1...1.0).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end
    end

    describe "and Float, Integer values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        (-2.0...2).step { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5.0...5).step(2) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields Float values incremented by a Float step" do
        (-1.0...1).step(0.5) { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end
    end

    describe "and String values" do
      it "yields String values adjusted by step and less than or equal to end" do
        ("A"..."AAA").step("A") { |x| ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA"])
      end

      it "raises a TypeError when passed an incompatible type step" do
        expect { ("A".."G").step([]) { } }.to raise_error(TypeError)
      end
    end
  end

  describe "with an endless range" do
    describe "and Integer values" do
      it "yield Integer values incremented by 1 when not passed a step" do
        (-2..).step { |x| break if x > 2; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1, 2])

        ScratchPad.record []
        (-2...).step { |x| break if x > 2; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2, -1, 0, 1, 2])
      end

      it "yields Integer values incremented by an Integer step" do
        (-5..).step(2) { |x| break if x > 3; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3])

        ScratchPad.record []
        (-5...).step(2) { |x| break if x > 3; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5, -3, -1, 1, 3])
      end

      it "yields Float values incremented by a Float step" do
        (-2..).step(1.5) { |x| break if x > 1.0; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])

        ScratchPad.record []
        (-2..).step(1.5) { |x| break if x > 1.0; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -0.5, 1.0])
      end
    end

    describe "and Float values" do
      it "yields Float values incremented by 1 and less than end when not passed a step" do
        (-2.0..).step { |x| break if x > 1.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])

        ScratchPad.record []
        (-2.0...).step { |x| break if x > 1.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-2.0, -1.0, 0.0, 1.0])
      end

      it "yields Float values incremented by an Integer step" do
        (-5.0..).step(2) { |x| break if x > 3.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])

        ScratchPad.record []
        (-5.0...).step(2) { |x| break if x > 3.5; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-5.0, -3.0, -1.0, 1.0, 3.0])
      end

      it "yields Float values incremented by a Float step" do
        (-1.0..).step(0.5) { |x| break if x > 0.6; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])

        ScratchPad.record []
        (-1.0...).step(0.5) { |x| break if x > 0.6; ScratchPad << x }
        expect(ScratchPad.recorded).to eql([-1.0, -0.5, 0.0, 0.5])
      end

      it "handles infinite values at the start" do
        (-Float::INFINITY..).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])

        ScratchPad.record []
        (-Float::INFINITY...).step(2) { |x| ScratchPad << x; break if ScratchPad.recorded.size == 3 }
        expect(ScratchPad.recorded).to eql([-Float::INFINITY, -Float::INFINITY, -Float::INFINITY])
      end
    end

    describe "and String values" do
      it "yields String values incremented by #succ and less than or equal to end when not passed a step" do
        ('A'..).step { |x| break if x > "D"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "B", "C", "D"])

        ScratchPad.record []
        ('A'...).step { |x| break if x > "D"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "B", "C", "D"])
      end

      it "yields String values incremented by #succ called Integer step times" do
        ('A'..).step(2) { |x| break if x > "F"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "C", "E"])

        ScratchPad.record []
        ('A'...).step(2) { |x| break if x > "F"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "C", "E"])
      end

      it "raises a TypeError when passed a Float step" do
        expect { ('A'..).step(2.0) { } }.to raise_error(TypeError)
        expect { ('A'...).step(2.0) { } }.to raise_error(TypeError)
      end

      it "yields String values adjusted by step" do
        ('A'..).step("A") { |x| break if x > "AAA"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA", "AAA"])

        ScratchPad.record []
        ('A'...).step("A") { |x| break if x > "AAA"; ScratchPad << x }
        expect(ScratchPad.recorded).to eq(["A", "AA", "AAA"])
      end

      it "raises a TypeError when passed an incompatible type step" do
        expect { ('A'..).step([]) { } }.to raise_error(TypeError)
        expect { ('A'...).step([]) { } }.to raise_error(TypeError)
      end
    end
  end

  describe "when no block is given" do
    it "raises an ArgumentError if step is 0" do
      expect { (-1..1).step(0) }.to raise_error(ArgumentError)
    end

    describe "returned Enumerator" do
      describe "size" do
        it "does not raise if step is incompatible" do
          obj = double("Range#step non-integer")
          expect { (1..2).step(obj) }.not_to raise_error
        end

        it "returns the ceil of range size divided by the number of steps" do
          expect((1..10).step(4).size).to eq(3)
          expect((1..10).step(3).size).to eq(4)
          expect((1..10).step(2).size).to eq(5)
          expect((1..10).step(1).size).to eq(10)
          expect((-5..5).step(2).size).to eq(6)
          expect((1...10).step(4).size).to eq(3)
          expect((1...10).step(3).size).to eq(3)
          expect((1...10).step(2).size).to eq(5)
          expect((1...10).step(1).size).to eq(9)
          expect((-5...5).step(2).size).to eq(5)
        end

        it "returns the ceil of range size divided by the number of steps even if step is negative" do
          expect((-1..1).step(-1).size).to eq(0)
          expect((1..-1).step(-1).size).to eq(3)
        end

        it "returns the correct number of steps when one of the arguments is a float" do
          expect((-1..1.0).step(0.5).size).to eq(5)
          expect((-1.0...1.0).step(0.5).size).to eq(4)
        end

        it "returns the range size when there's no step_size" do
          expect((-2..2).step.size).to eq(5)
          expect((-2.0..2.0).step.size).to eq(5)
          expect((-2..2.0).step.size).to eq(5)
          expect((-2.0..2).step.size).to eq(5)
          expect((1.0..6.4).step(1.8).size).to eq(4)
          expect((1.0..12.7).step(1.3).size).to eq(10)
          expect((-2...2).step.size).to eq(4)
          expect((-2.0...2.0).step.size).to eq(4)
          expect((-2...2.0).step.size).to eq(4)
          expect((-2.0...2).step.size).to eq(4)
          expect((1.0...6.4).step(1.8).size).to eq(3)
        end

        it "returns nil with begin and end are String" do
          expect(("A".."E").step("A").size).to eq(nil)
          expect(("A"..."E").step("A").size).to eq(nil)
        end

        it "return nil and not raises a TypeError if the first element is not of compatible type" do
          obj = double("Range#step non-comparable")
          expect(obj).to receive(:<=>).with(obj).and_return(1)
          enum = (obj..obj).step(obj)
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
            expect((1..10).step.class).to eq(Enumerator::ArithmeticSequence)
            expect((1..10).step(3).take(4)).to eq([1, 4, 7, 10])
          end
        end

        context "when begin is not defined and end is numeric" do
          it "returns an instance of Enumerator::ArithmeticSequence" do
            expect((..10).step.class).to eq(Enumerator::ArithmeticSequence)
          end
        end

        context "when range is endless" do
          it "returns an instance of Enumerator::ArithmeticSequence when begin is numeric" do
            expect((1..).step.class).to eq(Enumerator::ArithmeticSequence)
            expect((1..).step(2).take(3)).to eq([1, 3, 5])
          end

          it "returns an instance of Enumerator when begin is not numeric" do
            expect(("a"..).step("a").class).to eq(Enumerator)
            expect(("a"..).step("a").take(3)).to eq(%w[a aa aaa])
          end
        end

        context "when range is beginless and endless" do
          it "raises an ArgumentError" do
            expect { Range.new(nil, nil).step(1) }.to raise_error(ArgumentError)
          end
        end

        context "when begin and end are not numerics" do
          it "returns an instance of Enumerator" do
            expect(("a".."z").step("a").class).to eq(Enumerator)
            expect(("a".."z").step("a").take(4)).to eq(%w[a aa aaa aaaa])
          end
        end
      end
    end
  end
end
