require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#any?' do
  it 'returns whether any element is truthy' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.any?).to be true

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, false)
    expect(enum.any?).to be true

    enum = EnumerableSpecs::Numerous.new(1, 2, 3, nil)
    expect(enum.any?).to be true

    enum = EnumerableSpecs::Numerous.new(false, false)
    expect(enum.any?).to be false

    enum = EnumerableSpecs::Numerous.new(nil, nil)
    expect(enum.any?).to be false
  end

  it 'always returns false on empty enumeration' do
    enum = EnumerableSpecs::Empty.new
    expect(enum.any?).to be false
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMultiWithFalse.new
    expect(multi.any?).to be true
  end

  describe 'given a block' do
    it 'returns whether the block returns a truthy value for any element' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.any? { |i| i.even? }).to be true
      expect(enum.any? { |i| i.zero? }).to be false
    end

    it 'yields multiple arguments when #each yields multiple values' do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.any? { |*args| yielded << args; false }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end

  describe 'given a pattern argument' do
    it 'returns whether for any element element, pattern === element' do
      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.any?(/b/)).to be true

      enum = EnumerableSpecs::Numerous.new('a', 'ab', 'abc', 'abcd')
      expect(enum.any?(/e/)).to be false
    end

    it 'calls `#===` on the pattern' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      pattern = EnumerableSpecs::Pattern.new { false }
      enum.any?(pattern)
      expect(pattern.yielded).to contain_exactly([1], [2], [3], [4])
    end

    it 'always returns false on empty enumeration' do
      enum = EnumerableSpecs::Empty.new
      expect(enum.any?(Integer)).to be false
    end

    it 'handles nil value as a pattern as well' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3)
      expect(enum.any?(nil)).to be false

      enum = EnumerableSpecs::Numerous.new(false, false, false)
      expect(enum.any?(nil)).to be false
    end

    it 'calls the pattern with gathered array when yields multiple arguments' do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      multi.any?(pattern)
      expect(pattern.yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'ignores the block if there is an argument' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)

      expect {
        expect(enum.any?(Integer) { false }).to be true
      }.to complain(/given block not used/)
    end
  end
end
