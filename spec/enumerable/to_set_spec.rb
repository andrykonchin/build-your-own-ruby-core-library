require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#to_set" do
  it "returns a new Set created from self" do
    expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).to_set).to eq(Set[1, 2, 3, 4])
  end

  it "passes down passed blocks" do
    expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).to_set { |x| x * x }).to eq(Set[1, 4, 9, 16])
  end

  it "instantiates an object of provided as the first argument set class" do
    set = EnumerableSpecs::Numerous.new(1, 2, 3).to_set(EnumerableSpecs::SetSubclass)
    expect(set).to be_kind_of(EnumerableSpecs::SetSubclass)
    expect(set.to_a.sort).to eq([1, 2, 3])
  end

  it "passes extra arguments to #each" do
    enum = EnumerableSpecs::Numerous.new()
    set = enum.to_set(EnumerableSpecs::SetSubclassWithParameters, :a, :b, :c)
    expect(set.arguments_passed).to eq([:a, :b, :c])
  end

  it "gathers whole arrays as elements when #each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.to_set).to eq Set[[1, 2], [3, 4, 5], [6, 7, 8, 9]]
  end
end
