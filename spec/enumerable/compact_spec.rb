require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#compact' do
  it 'returns array without nil elements' do
    enum = EnumerableSpecs::Numerous.new(nil, 1, 2, nil, true)
    expect(enum.compact).to eq([1, 2, true])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.compact).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
  end
end
