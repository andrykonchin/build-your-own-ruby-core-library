require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#end" do
  it "end returns the last element of self" do
    expect((-1..1).end).to eq(1)
    expect((0..1).end).to eq(1)
    expect(("A".."Q").end).to eq("Q")
    expect(("A"..."Q").end).to eq("Q")
    expect((0xffff...0xfffff).end).to eq(1048575)
    expect((0.5..2.4).end).to eq(2.4)
  end
end
