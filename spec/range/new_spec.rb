require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range.new' do
  it 'constructs a range using the given begin and end' do
    range = Range.new(0, 1)

    expect(range.begin).to eq(0)
    expect(range.end).to eq(1)
  end

  it 'includes the end object when the third parameter is omitted' do
    range = Range.new(0, 1)
    expect(range.exclude_end?).to be false
  end

  it 'excludes end when the third parameter is a truthy value' do
    expect(Range.new(0, 1, true).exclude_end?).to be true
    expect(Range.new(0, 1, Object.new).exclude_end?).to be true
    expect(Range.new(0, 1, 'a').exclude_end?).to be true
  end

  it 'includes end when the third parameter is a falsy value' do
    expect(Range.new(0, 1, nil).exclude_end?).to be false
    expect(Range.new(0, 1, false).exclude_end?).to be false
  end

  it "raises an ArgumentError if begin or end doesn't respond to #<=> and range is finit" do
    expect {
      Range.new(Object.new, 1)
    }.to raise_error(ArgumentError, 'bad value for range')

    expect {
      Range.new(0, Object.new)
    }.to raise_error(ArgumentError, 'bad value for range')
  end

  it "raises ArgumentError if begin and end respond to #<=> but aren't comparable and range is finit" do
    a = double('begin', '<=>': nil)
    b = double('end', '<=>': nil)

    expect {
      Range.new(a, b)
    }.to raise_error(ArgumentError, 'bad value for range')
  end

  it "doesn't raise ArgumentError if begin or end doesn't respond to #<=> and range is infinit" do
    expect(Range.new(Object.new, nil)).to be_an_instance_of(Range)
    expect(Range.new(nil, Object.new)).to be_an_instance_of(Range)
  end

  describe 'beginless/endless range' do
    it 'allows beginless begin boundary' do
      range = Range.new(nil, 1)
      expect(range.begin).to be_nil
    end

    it 'allows endless end boundary' do
      range = Range.new(1, nil)
      expect(range.end).to be_nil
    end
  end

  it 'creates a frozen range if the class is Range.class' do
    expect(Range.new(1, 2).frozen?).to be true
  end

  it 'does not create a frozen range if the class is not Range.class' do
    expect(Class.new(Range).new(1, 2).frozen?).to be false
  end
end
