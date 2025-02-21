require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#overlap?" do
  it "returns true if other Range overlaps self" do
    expect((0..2).overlap?(1..3)).to eq(true)
    expect((1..3).overlap?(0..2)).to eq(true)
    expect((0..2).overlap?(0..2)).to eq(true)
    expect((0..3).overlap?(1..2)).to eq(true)
    expect((1..2).overlap?(0..3)).to eq(true)

    expect(('a'..'c').overlap?('b'..'d')).to eq(true)
  end

  it "returns false if other Range does not overlap self" do
    expect((0..2).overlap?(3..4)).to eq(false)
    expect((0..2).overlap?(-4..-1)).to eq(false)

    expect(('a'..'c').overlap?('d'..'f')).to eq(false)
  end

  it "raises TypeError when called with non-Range argument" do
    expect {
      (0..2).overlap?(1)
    }.to raise_error(TypeError, "wrong argument type Integer (expected Range)")
  end

  it "returns true when beginningless and endless Ranges overlap" do
    expect((0..2).overlap?(..3)).to eq(true)
    expect((0..2).overlap?(..1)).to eq(true)
    expect((0..2).overlap?(..0)).to eq(true)

    expect((..3).overlap?(0..2)).to eq(true)
    expect((..1).overlap?(0..2)).to eq(true)
    expect((..0).overlap?(0..2)).to eq(true)

    expect((0..2).overlap?(-1..)).to eq(true)
    expect((0..2).overlap?(1..)).to eq(true)
    expect((0..2).overlap?(2..)).to eq(true)

    expect((-1..).overlap?(0..2)).to eq(true)
    expect((1..).overlap?(0..2)).to eq(true)
    expect((2..).overlap?(0..2)).to eq(true)

    expect((0..).overlap?(2..)).to eq(true)
    expect((..0).overlap?(..2)).to eq(true)
  end

  it "returns false when beginningless and endless Ranges do not overlap" do
    expect((0..2).overlap?(..-1)).to eq(false)
    expect((0..2).overlap?(3..)).to eq(false)

    expect((..-1).overlap?(0..2)).to eq(false)
    expect((3..).overlap?(0..2)).to eq(false)
  end

  it "returns false when Ranges are not compatible" do
    expect((0..2).overlap?('a'..'d')).to eq(false)
  end

  it "return false when self is empty" do
    expect((2..0).overlap?(1..3)).to eq(false)
    expect((2...2).overlap?(1..3)).to eq(false)
    expect((1...1).overlap?(1...1)).to eq(false)
    expect((2..0).overlap?(2..0)).to eq(false)

    expect(('c'..'a').overlap?('b'..'d')).to eq(false)
    expect(('a'...'a').overlap?('b'..'d')).to eq(false)
    expect(('b'...'b').overlap?('b'...'b')).to eq(false)
    expect(('c'...'a').overlap?('c'...'a')).to eq(false)
  end

  it "return false when other Range is empty" do
    expect((1..3).overlap?(2..0)).to eq(false)
    expect((1..3).overlap?(2...2)).to eq(false)

    expect(('b'..'d').overlap?('c'..'a')).to eq(false)
    expect(('b'..'d').overlap?('c'...'c')).to eq(false)
  end

  it "takes into account exclusive end" do
    expect((0...2).overlap?(2..4)).to eq(false)
    expect((2..4).overlap?(0...2)).to eq(false)

    expect(('a'...'c').overlap?('c'..'e')).to eq(false)
    expect(('c'..'e').overlap?('a'...'c')).to eq(false)
  end
end
