require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#sort' do
  it 'sorts by the natural order as defined by <=>' do
    enum = EnumerableSpecs::Numerous.new(3, 1, 4, 6, 2, 5)
    expect(enum.sort).to eq([1, 2, 3, 4, 5, 6])
  end

  it 'sorts in order determined by a block if the block is given' do
    enum = EnumerableSpecs::Numerous.new(3, 1, 4, 6, 2, 5)
    expect(enum.sort { |a, b| b <=> a }).to eq([6, 5, 4, 3, 2, 1])
  end

  it 'raises a NoMethodError if elements do not respond to <=>' do
    enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new, BasicObject.new)

    expect {
      enum.sort
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it "raises an error if objects can't be compared, that is <=> returns nil" do
    enum = EnumerableSpecs::Numerous.new(EnumerableSpecs::Uncomparable.new, EnumerableSpecs::Uncomparable.new)

    expect {
      enum.sort
    }.to raise_error(ArgumentError, 'comparison of EnumerableSpecs::Uncomparable with EnumerableSpecs::Uncomparable failed')
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.sort { |a, b| a <=> b }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it 'yields multiple values as array' do
      yielded = Set.new
      multi = EnumerableSpecs::YieldsMulti.new
      multi.sort { |*args| yielded += args; 0 }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end
end
