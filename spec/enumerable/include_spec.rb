require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#include?' do
  it 'returns whether enumerable contains an object' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.include?(2)).to be true
    expect(enum.include?(5)).to be false
  end

  it 'compares an argument with elements using #==' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.include?(EnumerableSpecs::Equals.new(2))).to be true
    expect(enum.include?(EnumerableSpecs::Equals.new(5))).to be false
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.include?([1, 2])).to be true
  end
end
