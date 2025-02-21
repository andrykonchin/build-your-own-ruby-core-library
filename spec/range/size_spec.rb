require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#size" do
  it "returns the number of elements in the range" do
    expect((1..16).size).to eq(16)
    expect((1...16).size).to eq(15)
  end

  it "returns 0 if last is less than first" do
    expect((16..0).size).to eq(0)
  end

  it 'returns Float::INFINITY for increasing, infinite ranges' do
    expect((0..Float::INFINITY).size).to eq(Float::INFINITY)
  end

  it 'returns Float::INFINITY for endless ranges if the start is numeric' do
    expect(eval("(1..)").size).to eq(Float::INFINITY)
  end

  it 'returns nil for endless ranges if the start is not numeric' do
    expect(eval("('z'..)").size).to eq(nil)
  end

  it 'raises TypeError if a range is not iterable' do
    expect { (1.0..16.0).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (1.0...16.0).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (1.0..15.9).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (1.1..16.0).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (1.1..15.9).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (16.0..0.0).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (Float::INFINITY..0).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (-Float::INFINITY..0).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (-Float::INFINITY..Float::INFINITY).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (..1).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (...0.5).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (..nil).size }.to raise_error(TypeError, /can't iterate from/)
    expect { (...'o').size }.to raise_error(TypeError, /can't iterate from/)
    expect { eval("(0.5...)").size }.to raise_error(TypeError, /can't iterate from/)
    expect { eval("([]...)").size }.to raise_error(TypeError, /can't iterate from/)
  end

  it "returns nil if first and last are not Numeric" do
    expect((:a..:z).size).to be_nil
    expect(('a'..'z').size).to be_nil
  end
end
