require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#to_a" do
  it "converts self to an array" do
    expect((-5..5).to_a).to eq([-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5])
    expect(('A'..'D').to_a).to eq(['A','B','C','D'])
    expect(('A'...'D').to_a).to eq(['A','B','C'])
    expect((0xfffd...0xffff).to_a).to eq([0xfffd,0xfffe])
    expect { (0.5..2.4).to_a }.to raise_error(TypeError)
  end

  it "returns empty array for descending-ordered" do
    expect((5..-5).to_a).to eq([])
    expect(('D'..'A').to_a).to eq([])
    expect(('D'...'A').to_a).to eq([])
    expect((0xffff...0xfffd).to_a).to eq([])
  end

  it "works with Ranges of 64-bit integers" do
    large = 1 << 40
    expect((large..large+1).to_a).to eq([1099511627776, 1099511627777])
  end

  it "works with Ranges of Symbols" do
    expect((:A..:z).to_a.size).to eq(58)
  end

  it "works for non-ASCII ranges" do
    expect(('Σ'..'Ω').to_a).to eq(["Σ", "Τ", "Υ", "Φ", "Χ", "Ψ", "Ω"])
  end

  it "throws an exception for endless ranges" do
    expect { eval("(1..)").to_a }.to raise_error(RangeError)
  end

  it "throws an exception for beginless ranges" do
    expect { (..1).to_a }.to raise_error(TypeError)
  end
end
