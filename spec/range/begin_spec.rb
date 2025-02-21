require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#begin" do
  it "returns the first element of self" do
    expect((-1..1).begin).to eq(-1)
    expect((0..1).begin).to eq(0)
    expect((0xffff...0xfffff).begin).to eq(65535)
    expect(('Q'..'T').begin).to eq('Q')
    expect(('Q'...'T').begin).to eq('Q')
    expect((0.5..2.4).begin).to eq(0.5)
  end
end
