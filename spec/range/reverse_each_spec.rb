require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#reverse_each" do
  it "traverses the Range in reverse order and passes each element to block" do
    a = []
    (1..3).reverse_each { |i| a << i }
    expect(a).to eq([3, 2, 1])

    a = []
    (1...3).reverse_each { |i| a << i }
    expect(a).to eq([2, 1])
  end

  it "returns self" do
    r = (1..3)
    expect(r.reverse_each { |x| }).to equal(r)
  end

  it "returns an Enumerator if no block given" do
    enum = (1..3).reverse_each
    expect(enum).to be_an_instance_of(Enumerator)
    expect(enum.to_a).to eq([3, 2, 1])
  end

  it "raises a TypeError for endless Ranges of Integers" do
    expect {
      (1..).reverse_each.take(3)
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  it "raises a TypeError for endless Ranges of non-Integers" do
    expect {
      ("a"..).reverse_each.take(3)
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  context "Integer boundaries" do
    it "supports beginningless Ranges" do
      expect((..5).reverse_each.take(3)).to eq([5, 4, 3])
    end
  end

  context "non-Integer boundaries" do
    it "uses #succ to iterate a Range of non-Integer elements" do
      y = double('y')
      x = double('x')

      expect(x).to receive(:succ).at_least(:once).and_return(y)
      expect(x).to receive(:<=>).with(y).at_least(:once).and_return(-1)
      #x.should_receive(:<=>).with(x).at_least(:once).and_return(0)
      #y.should_receive(:<=>).with(x).at_least(:once).and_return(1)
      expect(y).to receive(:<=>).with(y).at_least(:once).and_return(0)

      a = []
      (x..y).each { |i| a << i }
      expect(a).to eq([x, y])
    end

    it "uses #succ to iterate a Range of Strings" do
      a = []
      ('A'..'D').reverse_each { |i| a << i }
      expect(a).to eq(['D','C','B','A'])
    end

    it "uses #succ to iterate a Range of Symbols" do
      a = []
      (:A..:D).reverse_each { |i| a << i }
      expect(a).to eq([:D, :C, :B, :A])
    end

    it "raises a TypeError when `begin` value does not respond to #succ" do
      expect { (Time.now..Time.now).reverse_each { |x| x } }.to raise_error(TypeError, /can't iterate from Time/)
      expect { (//..//).reverse_each { |x| x } }.to raise_error(TypeError, /can't iterate from Regexp/)
      expect { ([]..[]).reverse_each { |x| x } }.to raise_error(TypeError, /can't iterate from Array/)
    end

    it "does not support beginningless Ranges" do
      expect {
        (..'a').reverse_each { |x| x }
      }.to raise_error(TypeError, /can't iterate from NilClass/)
    end
  end

  context "when no block is given" do
    describe "returned Enumerator size" do
      it "returns the Range size when Range size is finite" do
        expect((1..3).reverse_each.size).to eq(3)
      end

      #ruby_bug "#20936", "3.4"..."3.5" do
      #  it "returns Infinity when Range size is infinite" do
      #    (..3).reverse_each.size.should == Float::INFINITY
      #  end
      #end

      it "returns nil when Range size is unknown" do
        expect(('a'..'z').reverse_each.size).to eq(nil)
      end
    end
  end
end
