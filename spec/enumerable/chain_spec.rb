require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#chain' do
  before do
    ScratchPad.record []
  end

  it 'returns a chain of self and provided enumerables' do
    one = EnumerableSpecs::Numerous.new(1)
    two = EnumerableSpecs::Numerous.new(2, 3)
    three = EnumerableSpecs::Numerous.new(4, 5, 6)

    chain = one.chain(two, three)

    chain.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq [1, 2, 3, 4, 5, 6]
  end

  it 'returns an Enumerator::Chain' do
    expect(EnumerableSpecs::Numerous.new.chain).to be_an_instance_of(Enumerator::Chain)
  end

  it 'can be called without arguments' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    chain = enum.chain
    chain.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq [1, 2, 3, 4]
  end
end
