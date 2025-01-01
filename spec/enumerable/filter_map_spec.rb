require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#filter_map' do
  before :each do
    @numerous = EnumerableSpecs::Numerous.new(*(1..8).to_a)
  end

  it 'returns an empty array if there are no elements' do
    expect(EnumerableSpecs::Empty.new.filter_map { true }).to eq([])
  end

  it 'returns an array with truthy results of passing each element to block' do
    expect(@numerous.filter_map { |i| i * 2 if i.even? }).to eq([4, 8, 12, 16])
    expect(@numerous.filter_map { |i| i * 2 }).to eq([2, 4, 6, 8, 10, 12, 14, 16])
    expect(@numerous.filter_map { 0 }).to eq([0, 0, 0, 0, 0, 0, 0, 0])
    expect(@numerous.filter_map { false }).to eq([])
    expect(@numerous.filter_map { nil }).to eq([])
  end

  it 'returns an enumerator when no block given' do
    expect(@numerous.filter_map).to be_an_instance_of(Enumerator)
  end
end
