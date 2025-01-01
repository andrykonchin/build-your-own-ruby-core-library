require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#to_set" do
  it "returns a new Set created from self" do
    expect([1, 2, 3].to_set).to eq(Set[1, 2, 3])
    expect({a: 1, b: 2}.to_set).to eq(Set[[:b, 2], [:a, 1]])
  end

  it "passes down passed blocks" do
    expect([1, 2, 3].to_set { |x| x * x }).to eq(Set[1, 4, 9])
  end

  it "instantiates an object of provided as the first argument set class" do
    set = [1, 2, 3].to_set(EnumerableSpecs::SetSubclass)
    expect(set).to be_kind_of(EnumerableSpecs::SetSubclass)
    expect(set.to_a.sort).to eq([1, 2, 3])
  end
end
