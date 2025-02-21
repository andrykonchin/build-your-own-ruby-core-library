require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#==" do
  #it_behaves_like :range_eql, :==

  it "returns true if other has same begin, end, and exclude_end? values" do
    expect((0..2).==(0..2)).to eq(true)
    expect(('G'..'M').==('G'..'M')).to eq(true)
    expect((0.5..2.4).==(0.5..2.4)).to eq(true)
    expect((5..10).==(Range.new(5,10))).to eq(true)
    expect(('D'..'V').==(Range.new('D','V'))).to eq(true)
    expect((0.5..2.4).==(Range.new(0.5, 2.4))).to eq(true)
    expect((0xffff..0xfffff).==(0xffff..0xfffff)).to eq(true)
    expect((0xffff..0xfffff).==(Range.new(0xffff,0xfffff))).to eq(true)

    a = RangeSpecs::Xs.new(3)..RangeSpecs::Xs.new(5)
    b = Range.new(RangeSpecs::Xs.new(3), RangeSpecs::Xs.new(5))
    expect(a.==(b)).to eq(true)
  end

  it "returns false if one of the attributes differs" do
    expect(('Q'..'X').==('A'..'C')).to eq(false)
    expect(('Q'...'X').==('Q'..'W')).to eq(false)
    expect(('Q'..'X').==('Q'...'X')).to eq(false)
    expect((0.5..2.4).==(0.5...2.4)).to eq(false)
    expect((1482..1911).==(1482...1911)).to eq(false)
    expect((0xffff..0xfffff).==(0xffff...0xfffff)).to eq(false)

    a = RangeSpecs::Xs.new(3)..RangeSpecs::Xs.new(5)
    b = Range.new(RangeSpecs::Ys.new(3), RangeSpecs::Ys.new(5))
    expect(a.==(b)).to eq(false)
  end

  it "returns false if other is not a Range" do
    expect((1..10).==(1)).to eq(false)
    expect((1..10).==('a')).to eq(false)
    expect((1..10).==(double('x'))).to eq(false)
  end

  it "returns true for subclasses of Range" do
    expect(Range.new(1, 2).==(RangeSpecs::MyRange.new(1, 2))).to eq(true)

    a = Range.new(RangeSpecs::Xs.new(3), RangeSpecs::Xs.new(5))
    b = RangeSpecs::MyRange.new(RangeSpecs::Xs.new(3), RangeSpecs::Xs.new(5))
    expect(a.==(b)).to eq(true)
  end

  it "works for endless Ranges" do
    expect(eval("(1..)").==(eval("(1..)"))).to eq(true)
    expect(eval("(0.5...)").==(eval("(0.5...)"))).to eq(true)
    expect(eval("(1..)").==(eval("(1...)"))).to eq(false)
  end

  it "returns true if the endpoints are ==" do
    expect(0..1).to eq(0..1.0)
  end

  it "returns true if the endpoints are == for endless ranges" do
    expect(eval("(1.0..)")).to eq(eval("(1.0..)"))
  end

  it "returns true if the endpoints are == for beginless ranges" do
    expect(...10).to eq(...10)
  end
end
