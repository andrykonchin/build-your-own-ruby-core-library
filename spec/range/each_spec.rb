require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#each" do
  it "passes each element to the given block by using #succ" do
    a = []
    (-5..5).each { |i| a << i }
    expect(a).to eq([-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5])

    a = []
    ('A'..'D').each { |i| a << i }
    expect(a).to eq(['A','B','C','D'])

    a = []
    ('A'...'D').each { |i| a << i }
    expect(a).to eq(['A','B','C'])

    a = []
    (0xfffd...0xffff).each { |i| a << i }
    expect(a).to eq([0xfffd, 0xfffe])

    y = double('y')
    x = double('x')
    expect(x).to receive(:<=>).with(y).at_least(:once).and_return(-1)
    expect(x).to receive(:<=>).with(x).at_least(:once).and_return(0)
    expect(x).to receive(:succ).at_least(:once).and_return(y)
    expect(y).to receive(:<=>).with(x).at_least(:once).and_return(1)
    expect(y).to receive(:<=>).with(y).at_least(:once).and_return(0)

    a = []
    (x..y).each { |i| a << i }
    expect(a).to eq([x, y])
  end

  it "works for non-ASCII ranges" do
    a = []
    ('Σ'..'Ω').each { |i| a << i }
    expect(a).to eq(["Σ", "Τ", "Υ", "Φ", "Χ", "Ψ", "Ω"])
  end

  it "works with endless ranges" do
    a = []
    (-2..).each { |x| break if x > 2; a << x }
    expect(a).to eq([-2, -1, 0, 1, 2])

    a = []
    (-2...).each { |x| break if x > 2; a << x }
    expect(a).to eq([-2, -1, 0, 1, 2])
  end

  it "works with String endless ranges" do
    a = []
    ('A'..).each { |x| break if x > "D"; a << x }
    expect(a).to eq(["A", "B", "C", "D"])

    a = []
    ('A'...).each { |x| break if x > "D"; a << x }
    expect(a).to eq(["A", "B", "C", "D"])
  end

  it "raises a TypeError beginless ranges" do
    expect { (..2).each { |x| x } }.to raise_error(TypeError)
  end

  it "raises a TypeError if the first element does not respond to #succ" do
    expect { (0.5..2.4).each { |i| i } }.to raise_error(TypeError)

    b = double('x')
    expect(a = double('1')).to receive(:<=>).with(b).and_return(1)

    expect { (a..b).each { |i| i } }.to raise_error(TypeError)
  end

  it "returns self" do
    range = 1..10
    expect(range.each{}).to equal(range)
  end

  it "returns an enumerator when no block given" do
    enum = (1..3).each
    expect(enum).to be_an_instance_of(Enumerator)
    expect(enum.to_a).to eq([1, 2, 3])
  end

  it "supports Time objects that respond to #succ" do
    t = Time.utc(1970)
    def t.succ; self + 1 end
    t_succ = t.succ
    def t_succ.succ; self + 1; end

    expect((t..t_succ).to_a).to eq([Time.utc(1970), Time.utc(1970, nil, nil, nil, nil, 1)])
    expect((t...t_succ).to_a).to eq([Time.utc(1970)])
  end

  it "passes each Symbol element by using #succ" do
    expect((:aa..:ac).each.to_a).to eq([:aa, :ab, :ac])
    expect((:aa...:ac).each.to_a).to eq([:aa, :ab])
  end

  describe "when no block is given" do
    describe "returned Enumerator" do
      it "size returns the enumerable size" do
        object = (1..3)
        expect(object.each.size).to eq(object.size)
      end
    end
  end
end
