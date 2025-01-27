require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#include?" do
  it "returns true if any element == argument for numbers" do
    elements = (0..5).to_a
    expect(EnumerableSpecs::Numerous.new(*elements).include?(5)).to eq(true)
    expect(EnumerableSpecs::Numerous.new(*elements).include?(10)).to eq(false)
    expect(EnumerableSpecs::Numerous.new(*elements).include?(EnumerableSpecs::ObjectEqual5.new)).to eq(true)
  end

  it "returns true if any element == argument for other objects" do
    elements = ('0'..'5').to_a + [EnumerableSpecs::ObjectEqual11.new]
    expect(EnumerableSpecs::Numerous.new(*elements).include?('5')).to eq(true)
    expect(EnumerableSpecs::Numerous.new(*elements).include?('10')).to eq(false)
    expect(EnumerableSpecs::Numerous.new(*elements).include?(EnumerableSpecs::ObjectEqual11.new)).to eq(true)
    expect(EnumerableSpecs::Numerous.new(*elements).include?('11')).to eq(true)
  end


  it "returns true if any member of enum equals obj when == compares different classes (legacy rubycon)" do
    # equality is tested with ==
    expect(EnumerableSpecs::Numerous.new(2,4,6,8,10).include?(2.0)).to eq(true)
    expect(EnumerableSpecs::Numerous.new(2,4,[6,8],10).include?([6, 8])).to eq(true)
    expect(EnumerableSpecs::Numerous.new(2,4,[6,8],10).include?([6.0, 8.0])).to eq(true)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.include?([1,2])).to eq(true)
  end
end
