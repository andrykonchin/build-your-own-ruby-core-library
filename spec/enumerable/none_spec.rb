require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#none?' do
  it 'returns whether no element is truthy' do
    enum = EnumerableSpecs::Numerous.new(nil, nil)
    expect(enum.none?).to be true

    enum = EnumerableSpecs::Numerous.new(false, false)
    expect(enum.none?).to be true

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.none?).to be false

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, false)
    expect(enum.none?).to be false

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, nil)
    expect(enum.none?).to be false
  end

  it 'always returns true on empty enumeration' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.none?).to be true
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMultiWithFalse.new
    expect(multi.none?).to be false
  end

  describe 'given a block' do
    it 'returns whether the block returns a truthy value for no element' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.none? { |i| i < 0 }).to be true
      expect(enum.none? { |i| i.even? }).to be false
    end

    it 'yields multiple arguments when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.none? { |*args| yielded << args; false }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end

  describe 'given a pattern argument' do
    it 'returns whether for no element element, pattern === element' do
      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.none?(/e/)).to be true

      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.none?(/b/)).to be false
    end

    it 'calls `#===` on the pattern' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      pattern = EnumerableSpecs::Pattern.new { false }
      enum.none?(pattern)
      expect(pattern.yielded).to contain_exactly([1], [2], [3], [4])
    end

    it 'always returns true on empty enumeration' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.none?(Integer)).to be true
    end

    it 'handles nil value as a pattern as well' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.none?(nil)).to be true

      enum = EnumerableSpecs::Numerous.new(false, false, false)
      expect(enum.none?(nil)).to be true
    end

    it 'calls the pattern with gathered array when yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      multi.none?(pattern)
      expect(pattern.yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'ignores the block if there is an argument' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

      expect {
        expect(enum.none?(String) { true }).to be true
      }.to complain(/given block not used/)
    end
  end
end
