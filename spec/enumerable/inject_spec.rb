require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#inject" do
  it "with argument takes a block with an accumulator (with argument as initial value) and the current element. Value of block becomes new accumulator" do
    a = []
    EnumerableSpecs::Numerous.new.inject(0) { |memo, i| a << [memo, i]; i }
    expect(a).to eq([[0, 2], [2, 5], [5, 3], [3, 6], [6, 1], [1, 4]])
    expect(EnumerableSpecs::EachDefiner.new(true, true, true).inject(nil) {|result, i| i && result}).to eq(nil)
  end

  it "produces an array of the accumulator and the argument when given a block with a *arg" do
    a = []
    EnumerableSpecs::Numerous.new(1,2).inject(0) {|*args| a << args; args[0] + args[1]}
    expect(a).to eq([[0, 1], [1, 2]])
  end

  it "can take two argument" do
    expect(EnumerableSpecs::Numerous.new(1, 2, 3).inject(10, :-)).to eq(4)
    expect(EnumerableSpecs::Numerous.new(1, 2, 3).inject(10, "-")).to eq(4)
  end

  it "converts non-Symbol method name argument to String with #to_str if two arguments" do
    name = double(to_str: "-")
    expect(EnumerableSpecs::Numerous.new(1, 2, 3).inject(10, name)).to eq(4)
  end

  it "raises TypeError when the second argument is not Symbol or String and it cannot be converted to String if two arguments" do
    expect { EnumerableSpecs::Numerous.new(1, 2, 3).inject(10, Object.new) }.to raise_error(TypeError, /is not a symbol nor a string/)
  end

  it "ignores the block if two arguments" do
    expect {
      expect(EnumerableSpecs::Numerous.new(1, 2, 3).inject(10, :-) { raise "we never get here"}).to eq(4)
    }.to complain(/#{__FILE__}:#{__LINE__-1}: warning: given block not used/, verbose: true)
  end

  it "does not warn when given a Symbol with $VERBOSE true" do
    expect {
      EnumerableSpecs::Numerous.new(1, 2).inject(0, :+)
      EnumerableSpecs::Numerous.new(1, 2).inject(:+)
    }.not_to complain(verbose: true)
  end

  it "can take a symbol argument" do
    expect(EnumerableSpecs::Numerous.new(10, 1, 2, 3).inject(:-)).to eq(4)
  end

  it "can take a String argument" do
    expect(EnumerableSpecs::Numerous.new(10, 1, 2, 3).inject("-")).to eq(4)
  end

  it "converts non-Symbol method name argument to String with #to_str" do
    name = double(to_str: "-")
    expect(EnumerableSpecs::Numerous.new(10, 1, 2, 3).inject(name)).to eq(4)
  end

  it "raises TypeError when passed not Symbol or String method name argument and it cannot be converted to String" do
    expect { EnumerableSpecs::Numerous.new(10, 1, 2, 3).inject(Object.new) }.to raise_error(TypeError, /is not a symbol nor a string/)
  end

  it "without argument takes a block with an accumulator (with first element as initial value) and the current element. Value of block becomes new accumulator" do
    a = []
    EnumerableSpecs::Numerous.new.inject { |memo, i| a << [memo, i]; i }
    expect(a).to eq([[2, 5], [5, 3], [3, 6], [6, 1], [1, 4]])
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.inject([]) {|acc, e| acc << e }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
  end

  it "with inject arguments(legacy rubycon)" do
    # with inject argument
    expect(EnumerableSpecs::EachDefiner.new().inject(1) {|acc,x| 999 }).to eq(1)
    expect(EnumerableSpecs::EachDefiner.new(2).inject(1) {|acc,x| 999 }).to eq(999)
    expect(EnumerableSpecs::EachDefiner.new(2).inject(1) {|acc,x| acc }).to eq(1)
    expect(EnumerableSpecs::EachDefiner.new(2).inject(1) {|acc,x| x }).to eq(2)

    expect(EnumerableSpecs::EachDefiner.new(1,2,3,4).inject(100) {|acc,x| acc + x }).to eq(110)
    expect(EnumerableSpecs::EachDefiner.new(1,2,3,4).inject(100) {|acc,x| acc * x }).to eq(2400)

    expect(EnumerableSpecs::EachDefiner.new('a','b','c').inject("z") {|result, i| i+result}).to eq("cbaz")
  end

  it "without inject arguments(legacy rubycon)" do
    # no inject argument
    expect(EnumerableSpecs::EachDefiner.new(2).inject {|acc,x| 999 }) .to eq(2)
    expect(EnumerableSpecs::EachDefiner.new(2).inject {|acc,x| acc }).to eq(2)
    expect(EnumerableSpecs::EachDefiner.new(2).inject {|acc,x| x }).to eq(2)

    expect(EnumerableSpecs::EachDefiner.new(1,2,3,4).inject {|acc,x| acc + x }).to eq(10)
    expect(EnumerableSpecs::EachDefiner.new(1,2,3,4).inject {|acc,x| acc * x }).to eq(24)

    expect(EnumerableSpecs::EachDefiner.new('a','b','c').inject {|result, i| i+result}).to eq("cba")
    expect(EnumerableSpecs::EachDefiner.new(3, 4, 5).inject {|result, i| result*i}).to eq(60)
    expect(EnumerableSpecs::EachDefiner.new([1], 2, 'a','b').inject{|r,i| r<<i}).to eq([1, 2, 'a', 'b'])
  end

  it "returns nil when fails(legacy rubycon)" do
    expect(EnumerableSpecs::EachDefiner.new().inject {|acc,x| 999 }).to eq(nil)
  end

  it "tolerates increasing a collection size during iterating Array" do
    array = [:a, :b, :c]
    ScratchPad.record []
    i = 0

    array.inject(nil) do |_, e|
      ScratchPad << e
      array << i if i < 100
      i += 1
    end

    actual = ScratchPad.recorded
    expected = [:a, :b, :c] + (0..99).to_a
    expect(actual.sort_by(&:to_s)).to eq(expected.sort_by(&:to_s))
  end
end
