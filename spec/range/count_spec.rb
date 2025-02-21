require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#count" do
  it "returns Infinity for beginless ranges without arguments or blocks" do
    inf = Float::INFINITY
    expect(eval("('a'...)").count).to eq(inf)
    expect(eval("(7..)").count).to eq(inf)
    expect((...'a').count).to eq(inf)
    expect((...nil).count).to eq(inf)
    expect((..10.0).count).to eq(inf)
  end
end
