require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#cycle' do
  it 'calls the block with each element, then does so again, until it has done so n times' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    yielded = []
    enum.cycle(3) { |e| yielded << e }
    expect(yielded).to eq([1, 2, 1, 2, 1, 2])
  end

  it 'returns nil' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    expect(enum.cycle(3) {}).to be_nil
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    expect(enum.cycle(3)).to be_an_instance_of(Enumerator)
    expect(enum.cycle(3).to_a).to eq([1, 2, 1, 2, 1, 2])

    yielded = []
    enum.cycle(3).each { |e| yielded << e }
    expect(yielded).to eq([1, 2, 1, 2, 1, 2])
  end

  it 'does nothing when argument is negative' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    ScratchPad.record nil

    enum.cycle(-1) { ScratchPad.record :called }
    expect(ScratchPad.recorded).to be_nil
  end

  it 'does nothing when argument is 0' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    ScratchPad.record nil

    enum.cycle(0) { ScratchPad.record :called }
    expect(ScratchPad.recorded).to be_nil
  end

  it 'cycles forever when argument is nil' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    stop_at = 10

    yielded = []
    i = 0
    enum.cycle(nil) do |e|
      yielded << e

      i += 1
      break if i == stop_at
    end

    expect(yielded).to eq([1, 2, 1, 2, 1, 2, 1, 2, 1, 2])
  end

  it 'cycles forever when no argument given' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    stop_at = 10

    yielded = []
    i = 0
    enum.cycle do |e|
      yielded << e

      i += 1
      break if i == stop_at
    end

    expect(yielded).to eq([1, 2, 1, 2, 1, 2, 1, 2, 1, 2])
  end

  it 'calls #each at most once' do
    enum = EnumerableSpecs::EachCounter.new(1, 2)
    enum.cycle(6) {}
    expect(enum.times_called).to eq(1)
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.cycle(1) { |*args| yielded << args }
    expect(yielded).to eq([[[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]]])
  end

  describe 'argument conversion to Integer' do
    it 'converts the passed argument to an Integer using #to_int' do
      enum = EnumerableSpecs::Numerous.new(1, 2)
      n = double('n', to_int: 3)
      yielded = []

      enum.cycle(n) { |e| yielded << e }
      expect(yielded).to eq([1, 2, 1, 2, 1, 2])
    end

    it 'raises a TypeError if the passed argument does not respond to #to_int' do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.cycle('a') {} }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
    end

    it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
      enum = EnumerableSpecs::Numerous.new
      n = double('n', to_int: 'a')

      expect {
        enum.cycle(n) {}
      }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns enum size * cycle argument' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2)
          expect(enum.cycle(3).size).to eq(6)
        end

        it 'size returns 0 when the argument is negative' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2)
          expect(enum.cycle(-1).size).to eq(0)
        end

        it 'size returns 0 when the argument is 0' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2)
          expect(enum.cycle(0).size).to eq(0)
        end

        it 'size returns Float::INFINITY when argument is nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2)
          expect(enum.cycle(nil).size).to eq(Float::INFINITY)
        end

        it 'size returns Float::INFINITY when no argument is passed' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2)
          expect(enum.cycle.size).to eq(Float::INFINITY)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2)
          expect(enum.each_slice(3).size).to be_nil
        end
      end
    end
  end
end
