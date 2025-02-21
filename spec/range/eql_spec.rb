require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#eql?" do
  #it_behaves_like :range_eql, :eql?

  it "returns true if other has same begin, end, and exclude_end? values" do
    expect((0..2).eql?(0..2)).to eq(true)
    expect(('G'..'M').eql?('G'..'M')).to eq(true)
    expect((0.5..2.4).eql?(0.5..2.4)).to eq(true)
    expect((5..10).eql?(Range.new(5,10))).to eq(true)
    expect(('D'..'V').eql?(Range.new('D','V'))).to eq(true)
    expect((0.5..2.4).eql?(Range.new(0.5, 2.4))).to eq(true)
    expect((0xffff..0xfffff).eql?(0xffff..0xfffff)).to eq(true)
    expect((0xffff..0xfffff).eql?(Range.new(0xffff,0xfffff))).to eq(true)

    a = RangeSpecs::Xs.new(3)..RangeSpecs::Xs.new(5)
    b = Range.new(RangeSpecs::Xs.new(3), RangeSpecs::Xs.new(5))
    expect(a.eql?(b)).to eq(true)
  end

  it "returns false if one of the attributes differs" do
    expect(('Q'..'X').eql?('A'..'C')).to eq(false)
    expect(('Q'...'X').eql?('Q'..'W')).to eq(false)
    expect(('Q'..'X').eql?('Q'...'X')).to eq(false)
    expect((0.5..2.4).eql?(0.5...2.4)).to eq(false)
    expect((1482..1911).eql?(1482...1911)).to eq(false)
    expect((0xffff..0xfffff).eql?(0xffff...0xfffff)).to eq(false)

    a = RangeSpecs::Xs.new(3)..RangeSpecs::Xs.new(5)
    b = Range.new(RangeSpecs::Ys.new(3), RangeSpecs::Ys.new(5))
    expect(a.eql?(b)).to eq(false)
  end

  it "returns false if other is not a Range" do
    expect((1..10).eql?(1)).to eq(false)
    expect((1..10).eql?('a')).to eq(false)
    expect((1..10).eql?(double('x'))).to eq(false)
  end

  it "returns true for subclasses of Range" do
    expect(Range.new(1, 2).eql?(RangeSpecs::MyRange.new(1, 2))).to eq(true)

    a = Range.new(RangeSpecs::Xs.new(3), RangeSpecs::Xs.new(5))
    b = RangeSpecs::MyRange.new(RangeSpecs::Xs.new(3), RangeSpecs::Xs.new(5))
    expect(a.eql?(b)).to eq(true)
  end

  it "works for endless Ranges" do
    expect(eval("(1..)").eql?(eval("(1..)"))).to eq(true)
    expect(eval("(0.5...)").eql?(eval("(0.5...)"))).to eq(true)
    expect(eval("(1..)").eql?(eval("(1...)"))).to eq(false)
  end

  it "returns false if the endpoints are not eql?" do
    expect(0..1).not_to eql(0..1.0)
  end
end
