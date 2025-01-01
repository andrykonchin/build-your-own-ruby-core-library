require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#entries" do
  it "returns an array containing the elements" do
    numerous = EnumerableSpecs::Numerous.new(1, nil, 'a', 2, false, true)
    expect(numerous.entries).to eq([1, nil, "a", 2, false, true])
  end

  it "passes through the values yielded by #each_with_index" do
    expect([:a, :b].each_with_index.entries).to eq([[:a, 0], [:b, 1]])
  end

  it "passes arguments to each" do
    count = EnumerableSpecs::EachCounter.new(1, 2, 3)
    expect(count.entries(:hello, "world")).to eq([1, 2, 3])
    expect(count.arguments_passed).to eq([:hello, "world"])
  end
end
