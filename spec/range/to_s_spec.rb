require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#to_s" do
  it "provides a printable form of self" do
    expect((0..21).to_s).to eq("0..21")
    expect((-8..0).to_s).to eq("-8..0")
    expect((-411..959).to_s).to eq("-411..959")
    expect(('A'..'Z').to_s).to eq('A..Z')
    expect(('A'...'Z').to_s).to eq('A...Z')
    expect((0xfff..0xfffff).to_s).to eq("4095..1048575")
    expect((0.5..2.4).to_s).to eq("0.5..2.4")
  end

  it "can show endless ranges" do
    expect(eval("(1..)").to_s).to eq("1..")
    expect(eval("(1.0...)").to_s).to eq("1.0...")
  end

  it "can show beginless ranges" do
    expect((..1).to_s).to eq("..1")
    expect((...1.0).to_s).to eq("...1.0")
  end
end
