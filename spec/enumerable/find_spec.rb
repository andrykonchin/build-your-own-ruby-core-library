require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#find' do
  it 'returns the first element for which the block returns a truthy value' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.find { |e| e.even? }).to eq(2)
  end

  it 'returns an Enumerator if called without a block' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.find).to be_an_instance_of(Enumerator)
    expect(enum.find.to_a).to contain_exactly(1, 2, 3, 4)
    expect(enum.find.each { |e| e.even? }).to eq(2)

    if_none_proc = proc { 42 }
    expect(enum.find(if_none_proc).each { |i| i < 0 }).to eq(42)
  end

  it 'returns nil when no element found' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.find { |e| e < 0 }).to be_nil
  end

  it 'yields whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.find { |*args| yielded << args; false }
    expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
  end

  context 'when an argument given' do
    it 'calls a #call method on an argument, and returns its return value when no element found' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      if_none_proc = double('callable', call: 42)
      expect(enum.find(if_none_proc) { |e| e < 0 }).to eq(42)
    end

    it 'ignores a non-callable argument when element found' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.find(Object.new) { |e| e.even? }).to eq(2)
    end

    it 'handles nil value as if argument is not given' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.find(nil) { |e| e < 0 }).to be_nil
    end
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.find.size).to be_nil
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.find.size).to be_nil
        end
      end
    end
  end
end
