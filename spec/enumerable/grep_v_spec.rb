require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#grep_v" do
  before :each do
    @numerous = EnumerableSpecs::Numerous.new(*(0..9).to_a)
    def (@odd_matcher = BasicObject.new).===(obj)
      obj.odd?
    end
  end

  it "sets $~ in the block" do
    "z" =~ /z/ # Reset $~
    EnumerableSpecs::Numerous.new("abc", "def").grep_v(/e/) { |e|
      expect(e).to eq("abc")
      expect($~).to eq(nil)
    }

    # Set by the match of "def"
    expect($&).to eq("e")
  end

  it "does not set $~ when given no block" do
    "z" =~ /z/ # Reset $~
    expect(EnumerableSpecs::Numerous.new("abc", "def").grep_v(/e/)).to eq(["abc"])
    expect($&).to eq("z")
  end

  it "does not modify Regexp.last_match without block" do
    "z" =~ /z/ # Reset last match
    expect(EnumerableSpecs::Numerous.new("abc", "def").grep_v(/e/)).to eq(["abc"])
    expect(Regexp.last_match[0]).to eq("z")
  end

  it "correctly handles non-string elements" do
    'set last match' =~ /set last (.*)/
    expect(EnumerableSpecs::Numerous.new(:a, 'b', 'z', :c, 42, nil).grep_v(/[a-d]/)).to eq(['z', 42, nil])
    expect($1).to eq('match')

    o = double(to_str: 'hello')
    expect(EnumerableSpecs::Numerous.new(o).grep_v(/mm/).first).to equal(o)
  end

  describe "without block" do
    it "returns an Array of matched elements" do
      expect(@numerous.grep_v(@odd_matcher)).to eq([0, 2, 4, 6, 8])
    end

    it "compares pattern with gathered array when yielded with multiple arguments" do
      unmatcher = double("===": false)
      expect(EnumerableSpecs::YieldsMixed2.new.grep_v(unmatcher)).to eq(EnumerableSpecs::YieldsMixed2.gathered_yields)
    end

    it "raises an ArgumentError when not given a pattern" do
      expect { @numerous.grep_v }.to raise_error(ArgumentError)
    end
  end

  describe "with block" do
    it "returns an Array of matched elements that mapped by the block" do
      expect(@numerous.grep_v(@odd_matcher) { |n| n * 2 }).to eq([0, 4, 8, 12, 16])
    end

    it "calls the block with gathered array when yielded with multiple arguments" do
      unmatcher = double("===": false)
      expect(EnumerableSpecs::YieldsMixed2.new.grep_v(unmatcher){ |e| e }).to eq(EnumerableSpecs::YieldsMixed2.gathered_yields)
    end

    it "raises an ArgumentError when not given a pattern" do
      expect { @numerous.grep_v { |e| e } }.to raise_error(ArgumentError)
    end
  end
end
