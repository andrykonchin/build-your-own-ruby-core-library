require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#lazy' do
  it 'returns an instance of Enumerator::Lazy' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.lazy).to be_an_instance_of(Enumerator::Lazy)
    expect(enum.lazy.to_a).to eq([1, 2, 3, 4])
  end

  it 'yields multiple values as array when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    yielded = []
    multi.lazy.each { |*args| yielded << args }
    expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
  end

  describe 'Enumerable with size' do
    describe 'returned Enumerator' do
      it 'size returns the enumerable size' do
        enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        expect(enum.lazy.size).to eq(enum.size)
      end
    end
  end

  describe 'Enumerable with no size' do
    describe 'returned Enumerator' do
      it 'size returns nil' do
        enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        expect(enum.lazy.size).to be_nil
      end
    end
  end
end
