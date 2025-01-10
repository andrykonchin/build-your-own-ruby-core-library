require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#find_index' do
  it 'returns an index of the first element for which the block returns a truthy value' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.find_index { |e| e.even? }).to eq(1)
  end

  it 'returns an Enumerator if called without a block and without an argument' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.find_index).to be_an_instance_of(Enumerator)
    expect(enum.find_index.to_a).to contain_exactly(1, 2, 3, 4)
    expect(enum.find_index.each { |e| e.even? }).to eq(1)
  end

  it 'returns nil when no element found' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.find_index { |e| e < 0 }).to be_nil
  end

  it 'yields multiple arguments when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.find_index { |*args| yielded << args; false }
    expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
  end

  context 'when an argument given' do
    it 'returns index of the first element that equals the argument' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.find_index(4)).to eq(3)
    end

    it 'checks equality as object == element' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, 5)
      object = EnumerableSpecs::Equals.new(5)
      expect(enum.find_index(object)).to eq(4)
    end

    it "doesn't treat an argument's nil value as if it isn't given" do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4, nil)
      expect(enum.find_index(nil)).to eq(4)
    end

    it 'gathers whole arrays as elements when #each yields multiple' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.find_index([1, 2])).to eq(0)
    end

    it 'ignores block' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

      expect {
        expect(enum.find_index(4) { raise }).to eq(3) # rubocop:disable Lint/UnreachableLoop
      }.to complain(/warning: given block not used/)
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.find_index.size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.find_index.size).to be_nil
        end
      end
    end
  end
end
