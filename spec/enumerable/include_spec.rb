require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#include?" do
  it "returns true if any element == argument for numbers" do
    class EnumerableSpecIncludeP; def ==(obj) obj == 5; end; end

    elements = (0..5).to_a
    expect(EnumerableSpecs::Numerous.new(*elements).include?(5)).to eq(true)
    expect(EnumerableSpecs::Numerous.new(*elements).include?(10)).to eq(false)
    expect(EnumerableSpecs::Numerous.new(*elements).include?(EnumerableSpecIncludeP.new)).to eq(true)
  end

  it "returns true if any element == argument for other objects" do
    class EnumerableSpecIncludeP11; def ==(obj); obj == '11'; end; end

    elements = ('0'..'5').to_a + [EnumerableSpecIncludeP11.new]
    expect(EnumerableSpecs::Numerous.new(*elements).include?('5')).to eq(true)
    expect(EnumerableSpecs::Numerous.new(*elements).include?('10')).to eq(false)
    expect(EnumerableSpecs::Numerous.new(*elements).include?(EnumerableSpecIncludeP11.new)).to eq(true)
    expect(EnumerableSpecs::Numerous.new(*elements).include?('11')).to eq(true)
  end


  it "returns true if any member of enum equals obj when == compare different classes (legacy rubycon)" do
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
