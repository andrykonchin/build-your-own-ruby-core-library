require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Enumerable#grep_v' do
  it "returns an array of objects based on elements of self that don't match the given pattern" do
    enum = EnumerableSpecs::Numerous.new('a', 'b', 'ab', 'bc')
    expect(enum.grep_v(/a/)).to contain_exactly('b', 'bc')
  end

  it 'returns an array containing each element for which `pattern === element` is false' do
    enum = EnumerableSpecs::Numerous.new(1, -2, 3, -4)

    pattern = Object.new
    def pattern.===(v)
      v > 0
    end

    expect(enum.grep_v(pattern)).to contain_exactly(-2, -4)
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    pattern = EnumerableSpecs::Pattern.new { false }
    expect(multi.grep_v(pattern)).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    expect(pattern.yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
  end

  context 'given a block' do
    it 'calls the block with each non-matching element and returns an array containing each object returned by the block' do
      enum = EnumerableSpecs::Numerous.new('a', 'b', 'ab', 'bc')
      expect(enum.grep_v(/a/) { |s| s.to_sym }).to contain_exactly(:b, :bc)
    end

    it 'yields multiple values as array when #each yields multiple' do
      multi = EnumerableSpecs::YieldsMulti.new
      pattern = EnumerableSpecs::Pattern.new { false }
      yielded = []
      multi.grep_v(pattern) { |*args| yielded << args }
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end

    it 'sets $~ in the block' do
      skip "it's unclear how to implement in pure Ruby"

      'z' =~ /z/ # Reset $~
      EnumerableSpecs::Numerous.new('abc', 'def').grep_v(/e/) { |e|
        expect(e).to eq('abc')
        expect($~).to be_nil
      }

      # Set by the match of "def"
      expect($&).to eq('e')
    end
  end
end
