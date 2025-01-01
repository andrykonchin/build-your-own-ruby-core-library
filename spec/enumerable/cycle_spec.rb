require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#cycle" do
  describe "passed no argument or nil" do
    it "loops indefinitely" do
      [[],[nil]].each do |args|
        bomb = 10
        expect(
          EnumerableSpecs::Numerous.new.cycle(*args) do
            bomb -= 1
            break 42 if bomb <= 0
          end
        ).to eq(42)
        expect(bomb).to eq(0)
      end
    end

    it "returns nil if there are no elements" do
      out = EnumerableSpecs::Empty.new.cycle { break :nope }
      expect(out).to be_nil
    end

    it "yields successive elements of the array repeatedly" do
      b = []
      EnumerableSpecs::Numerous.new(1,2,3).cycle do |elem|
        b << elem
        break if b.size == 7
      end
      expect(b).to eq([1,2,3,1,2,3,1])
    end

    it "calls each at most once" do
      enum = EnumerableSpecs::EachCounter.new(1, 2)
      expect(enum.cycle.first(6)).to eq([1,2,1,2,1,2])
      expect(enum.times_called).to eq(1)
    end

    it "yields only when necessary" do
      enum = EnumerableSpecs::EachCounter.new(10, 20, 30)
      enum.cycle { |x| break if x == 20}
      expect(enum.times_yielded).to eq(2)
    end
  end

  describe "passed a number n as an argument" do
    it "returns nil and does nothing for non positive n" do
      expect(EnumerableSpecs::ThrowingEach.new.cycle(0) {}).to be_nil
      expect(EnumerableSpecs::NoEach.new.cycle(-22) {}).to be_nil
    end

    it "calls each at most once" do
      enum = EnumerableSpecs::EachCounter.new(1, 2)
      expect(enum.cycle(3).to_a).to eq([1,2,1,2,1,2])
      expect(enum.times_called).to eq(1)
    end

    it "yields only when necessary" do
      enum = EnumerableSpecs::EachCounter.new(10, 20, 30)
      enum.cycle(3) { |x| break if x == 20}
      expect(enum.times_yielded).to eq(2)
    end

    it "tries to convert n to an Integer using #to_int" do
      enum = EnumerableSpecs::Numerous.new(3, 2, 1)
      expect(enum.cycle(2.3).to_a).to eq([3, 2, 1, 3, 2, 1])

      obj = double('to_int')
      expect(obj).to receive(:to_int).and_return(2)
      expect(enum.cycle(obj).to_a).to eq([3, 2, 1, 3, 2, 1])
    end

    it "raises a TypeError when the passed n cannot be coerced to Integer" do
      enum = EnumerableSpecs::Numerous.new
      expect{ enum.cycle("cat"){} }.to raise_error(TypeError)
    end

    it "raises an ArgumentError if more arguments are passed" do
      enum = EnumerableSpecs::Numerous.new
      expect{ enum.cycle(1, 2) {} }.to raise_error(ArgumentError)
    end

    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.cycle(2).to_a).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9], [1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        describe "size" do
          before do
            @enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
            @empty_enum = EnumerableSpecs::EmptyWithSize.new
          end

          it "should be the result of multiplying the enumerable size by the argument passed" do
            expect(@enum.cycle(2).size).to eq(@enum.size * 2)
            expect(@enum.cycle(7).size).to eq(@enum.size * 7)
            expect(@enum.cycle(0).size).to eq(0)
            expect(@empty_enum.cycle(2).size).to eq(0)
          end

          it "should be zero when the argument passed is 0 or less" do
            expect(@enum.cycle(-1).size).to eq(0)
          end

          it "should be Float::INFINITY when no argument is passed" do
            expect(@enum.cycle.size).to eq(Float::INFINITY)
          end
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).cycle.size).to eq(nil)
        end
      end
    end
  end
end
