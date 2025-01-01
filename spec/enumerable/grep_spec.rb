require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#grep" do
  before :each do
    @a = EnumerableSpecs::EachDefiner.new( 2, 4, 6, 8, 10)
  end

  it "grep without a block should return an array of all elements === pattern" do
    class EnumerableSpecGrep; def ===(obj); obj == '2'; end; end

    expect(EnumerableSpecs::Numerous.new('2', 'a', 'nil', '3', false).grep(EnumerableSpecGrep.new)).to eq(['2'])
  end

  it "grep with a block should return an array of elements === pattern passed through block" do
    class EnumerableSpecGrep2; def ===(obj); /^ca/ =~ obj; end; end

    expect(EnumerableSpecs::Numerous.new("cat", "coat", "car", "cadr", "cost").grep(EnumerableSpecGrep2.new) { |i| i.upcase }).to eq(["CAT", "CAR", "CADR"])
  end

  it "grep the enumerable (rubycon legacy)" do
    expect(EnumerableSpecs::EachDefiner.new().grep(1)).to eq([])
    expect(@a.grep(3..7)).to eq([4,6])
    expect(@a.grep(3..7) {|a| a+1}).to eq([5,7])
  end

  it "can use $~ in the block when used with a Regexp" do
    ary = ["aba", "aba"]
    expect(ary.grep(/a(b)a/) { $1 }).to eq(["b", "b"])
  end

  it "sets $~ in the block" do
    "z" =~ /z/ # Reset $~
    ["abc", "def"].grep(/b/) { |e|
      expect(e).to eq("abc")
      expect($&).to eq("b")
    }

    # Set by the failed match of "def"
    expect($~).to eq(nil)
  end

  it "does not set $~ when given no block" do
    "z" =~ /z/ # Reset $~
    expect(["abc", "def"].grep(/b/)).to eq(["abc"])
    expect($&).to eq("z")
  end

  it "does not modify Regexp.last_match without block" do
    "z" =~ /z/ # Reset last match
    expect(["abc", "def"].grep(/b/)).to eq(["abc"])
    expect(Regexp.last_match[0]).to eq("z")
  end

  it "correctly handles non-string elements" do
    'set last match' =~ /set last (.*)/
    expect([:a, 'b', 'z', :c, 42, nil].grep(/[a-d]/)).to eq([:a, 'b', :c])
    expect($1).to eq('match')

    o = Object.new
    def o.to_str
      'hello'
    end
    expect([o].grep(/ll/).first).to equal(o)
  end

  describe "with a block" do
    before :each do
      @numerous = EnumerableSpecs::Numerous.new(*(0..9).to_a)
      def (@odd_matcher = BasicObject.new).===(obj)
        obj.odd?
      end
    end

    it "returns an Array of matched elements that mapped by the block" do
      expect(@numerous.grep(@odd_matcher) { |n| n * 2 }).to eq([2, 6, 10, 14, 18])
    end

    it "calls the block with gathered array when yielded with multiple arguments" do
      expect(EnumerableSpecs::YieldsMixed2.new.grep(Object){ |e| e }).to eq(EnumerableSpecs::YieldsMixed2.gathered_yields)
    end

    it "raises an ArgumentError when not given a pattern" do
      expect { @numerous.grep { |e| e } }.to raise_error(ArgumentError)
    end
  end
end
