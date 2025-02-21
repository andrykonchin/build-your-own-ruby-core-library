require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#inspect' do
  it 'returns a string representation of self' do
    expect(Range.new(0, 1).inspect).to eq('0..1')
    expect(Range.new('A', 'Z').inspect).to eq('"A".."Z"')
  end

  it 'calls #inspect for self.begin and self.end' do
    a = double('begin', inspect: 'begin', '<=>': 1)
    b = double('end', inspect: 'end', '<=>': 1)
    range = Range.new(a, b)

    expect(range.inspect).to eq('begin..end')
  end

  it 'uses ... when a range excludes end' do
    range = Range.new(0, 1, true)
    expect(range.inspect).to eq('0...1')
  end

  it 'works for beginless ranges' do
    expect(Range.new(nil, 1).inspect).to eq('..1')
    expect(Range.new(nil, 1, true).inspect).to eq('...1')
  end

  it 'works for endless ranges' do
    expect(Range.new(1, nil).inspect).to eq('1..')
    expect(Range.new(1, nil, true).inspect).to eq('1...')
  end

  it 'works for nil, nil ranges' do
    expect(Range.new(nil, nil).inspect).to eq('nil..nil')
    expect(Range.new(nil, nil, true).inspect).to eq('nil...nil')
  end
end
