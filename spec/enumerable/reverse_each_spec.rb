require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#reverse_each' do
  it 'traverses enum in reverse order' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    yielded = []
    enum.reverse_each { |i| yielded << i }
    expect(yielded).to eq([4, 3, 2, 1])
  end

  it 'returns an Enumerator if no block given' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    e = enum.reverse_each
    expect(e).to be_an_instance_of(Enumerator)
    expect(e.to_a).to eq([4, 3, 2, 1])
  end

  it 'returns self if block given' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.reverse_each {}).to equal(enum)
  end

  it 'yields whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.reverse_each { |*args| yielded << args }
    expect(yielded).to eq([[[6, 7, 8, 9]], [[3, 4, 5]], [[1, 2]]])
  end

  describe 'Enumerable with size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the enumerable size' do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.reverse_each.size).to eq(enum.size)
        end
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns nil' do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.reverse_each.size).to be_nil
        end
      end
    end
  end
end
