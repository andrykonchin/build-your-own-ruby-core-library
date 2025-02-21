require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#size' do
  context 'Integer range' do
    it 'returns the number of elements if forward range' do
      expect(Range.new(1, 16).size).to eq(16)
      expect(Range.new(1, 16, true).size).to eq(15)
    end

    it 'returns 0 if backward range' do
      range = Range.new(16, 0)
      expect(range.size).to eq(0)
    end

    it 'returns 0 if empty range' do
      range = Range.new(0, 0, true)
      expect(range.size).to eq(0)
    end

    it 'returns 0 if infinite backward range' do
      range = Range.new(16, -Float::INFINITY)
      expect(range.size).to eq(0)
    end

    it 'returns Float::INFINITY if infinite forward range' do
      range = Range.new(0, Float::INFINITY)
      expect(range.size).to eq(Float::INFINITY)
    end

    it 'returns Float::INFINITY if endless range' do
      range = Range.new(1, nil)
      expect(range.size).to eq(Float::INFINITY)
    end
  end

  it 'returns nil if non-Integer range' do
    expect(Range.new(:a, :z).size).to be_nil
    expect(Range.new('a', 'z').size).to be_nil
  end

  it 'returns nil if non-Integer endless range' do
    range = Range.new('z', nil)
    expect(range.size).to be_nil
  end

  it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
    expect {
      Range.new(1.0, 16.0).size
    }.to raise_error(TypeError, "can't iterate from Float")

    expect {
      Range.new(nil, 1).size
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end
end
