require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#to_s' do
  it 'returns a string representation of self' do
    expect(Range.new(0, 1).to_s).to eq('0..1')
    expect(Range.new('A', 'Z').to_s).to eq('A..Z')
  end

  it 'calls #to_s for self.begin and self.end' do
    a = double('begin', to_s: 'begin', '<=>': 1)
    b = double('end', to_s: 'end', '<=>': 1)
    range = Range.new(a, b)

    expect(range.to_s).to eq('begin..end')
  end

  it 'uses ... if excluded end' do
    range = Range.new(0, 1, true)
    expect(range.to_s).to eq('0...1')
  end

  it 'uses "" for the left boundary if beginless range' do
    expect(Range.new(nil, 1).to_s).to eq('..1')
    expect(Range.new(nil, 1, true).to_s).to eq('...1')
  end

  it 'uses "" for the right boundary if endless range' do
    expect(Range.new(1, nil).to_s).to eq('1..')
    expect(Range.new(1, nil, true).to_s).to eq('1...')
  end

  it 'keeps only .. for (nil..nil) ranges' do
    expect(Range.new(nil, nil).to_s).to eq('..')
  end

  it 'keeps only ... for (nil...nil) ranges' do
    expect(Range.new(nil, nil, true).to_s).to eq('...')
  end
end
