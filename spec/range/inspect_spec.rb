require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#inspect" do
  it "provides a printable form, using #inspect to convert the start and end objects" do
    expect(('A'..'Z').inspect).to eq('"A".."Z"')
    expect(('A'...'Z').inspect).to eq('"A"..."Z"')

    expect((0..21).inspect).to eq("0..21")
    expect((-8..0).inspect).to eq("-8..0")
    expect((-411..959).inspect).to eq("-411..959")
    expect((0xfff..0xfffff).inspect).to eq("4095..1048575")
    expect((0.5..2.4).inspect).to eq("0.5..2.4")
  end

  it "works for endless ranges" do
    expect(eval("(1..)").inspect).to eq("1..")
    expect(eval("(0.1...)").inspect).to eq("0.1...")
  end

  it "works for beginless ranges" do
    expect((..1).inspect).to eq("..1")
    expect((...0.1).inspect).to eq("...0.1")
  end

  it "works for nil ... nil ranges" do
    expect((..nil).inspect).to eq("nil..nil")
    expect(eval("(nil...)").inspect).to eq("nil...nil")
  end
end
