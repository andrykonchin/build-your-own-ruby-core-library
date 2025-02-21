require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#%" do
  it "works as a Range#step" do
    aseq = (1..10) % 2
    expect(aseq.class).to eq(Enumerator::ArithmeticSequence)
    expect(aseq.begin).to eq(1)
    expect(aseq.end).to eq(10)
    expect(aseq.step).to eq(2)
    expect(aseq.to_a).to eq([1, 3, 5, 7, 9])
  end

  it "produces an arithmetic sequence with a percent sign in #inspect" do
    expect(((1..10) % 2).inspect).to eq("((1..10).%(2))")
  end
end
