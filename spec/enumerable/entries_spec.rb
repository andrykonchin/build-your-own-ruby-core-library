require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#entries' do
  it 'returns an array containing the elements' do
    enum = EnumerableSpecs::Numerous.new(1, nil, 'a', 2, false, true)
    expect(enum.entries).to eq([1, nil, 'a', 2, false, true])
  end

  it 'passes extra arguments to #each' do
    enum = EnumerableSpecs::EachWithParameters.new
    enum.entries(:hello, 'world')
    expect(enum.arguments_passed).to eq([:hello, 'world'])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.entries).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
  end
end
