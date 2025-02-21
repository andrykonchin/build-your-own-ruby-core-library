require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#bsearch" do
  it "returns an Enumerator when not passed a block" do
    expect((0..1).bsearch).to be_an_instance_of(Enumerator)
  end

  describe "when no block is given" do
    describe "returned Enumerator" do
      it "size returns nil" do
        expect((1..3).bsearch.size).to eq(nil)
      end
    end
  end

  it "raises a TypeError if the block returns an Object" do
    expect { (0..1).bsearch { Object.new } }.to raise_error(TypeError, "wrong argument type Object (must be numeric, true, false or nil)")
  end

  it "raises a TypeError if the block returns a String and boundaries are Integer values" do
    expect { (0..1).bsearch { "1" } }.to raise_error(TypeError, "wrong argument type String (must be numeric, true, false or nil)")
  end

  it "raises a TypeError if the block returns a String and boundaries are Float values" do
    expect { (0.0..1.0).bsearch { "1" } }.to raise_error(TypeError, "wrong argument type String (must be numeric, true, false or nil)")
  end

  it "raises a TypeError if the Range has Object values" do
    value = double("range bsearch")
    r = Range.new value, value

    expect { r.bsearch { true } }.to raise_error(TypeError, "can't do binary search for RSpec::Mocks::Double")
  end

  it "raises a TypeError if the Range has String values" do
    expect { ("a".."e").bsearch { true } }.to raise_error(TypeError, "can't do binary search for String")
  end

  it "raises TypeError when non-Numeric begin/end and block not passed" do
    expect { ("a".."e").bsearch }.to raise_error(TypeError, "can't do binary search for String")
  end

  context "with Integer values" do
    context "with a block returning true or false" do
      it "returns nil if the block returns false for every element" do
        expect((0...3).bsearch { |x| x > 3 }).to be_nil
      end

      it "returns nil if the block returns nil for every element" do
        expect((0..3).bsearch { |x| nil }).to be_nil
      end

      it "returns minimum element if the block returns true for every element" do
        expect((-2..4).bsearch { |x| x < 4 }).to eq(-2)
      end

      it "returns the smallest element for which block returns true" do
        expect((0..4).bsearch { |x| x >= 2 }).to eq(2)
        expect((-1..4).bsearch { |x| x >= 1 }).to eq(1)
      end

      it "returns the last element if the block returns true for the last element" do
        expect((0..4).bsearch { |x| x >= 4 }).to eq(4)
        expect((0...4).bsearch { |x| x >= 3 }).to eq(3)
      end
    end

    context "with a block returning negative, zero, positive numbers" do
      it "returns nil if the block returns less than zero for every element" do
        expect((0..3).bsearch { |x| x <=> 5 }).to be_nil
      end

      it "returns nil if the block returns greater than zero for every element" do
        expect((0..3).bsearch { |x| x <=> -1 }).to be_nil

      end

      it "returns nil if the block never returns zero" do
        expect((0..3).bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
      end

      it "accepts (+/-)Float::INFINITY from the block" do
        expect((0..4).bsearch { |x| Float::INFINITY }).to be_nil
        expect((0..4).bsearch { |x| -Float::INFINITY }).to be_nil
      end

      it "returns an element at an index for which block returns 0.0" do
        result = (0..4).bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 }
        expect(result).to eq(2)
      end

      it "returns an element at an index for which block returns 0" do
        result = (0..4).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }
        expect([1, 2]).to include(result)
      end
    end

    it "returns nil for empty ranges" do
      expect((0...0).bsearch { true }).to eq(nil)
      expect((0...0).bsearch { false }).to eq(nil)
      expect((0...0).bsearch { 1 }).to eq(nil)
      expect((0...0).bsearch { 0 }).to eq(nil)
      expect((0...0).bsearch { -1 }).to eq(nil)

      expect((4..2).bsearch { true }).to eq(nil)
      expect((4..2).bsearch { 1 }).to eq(nil)
      expect((4..2).bsearch { 0 }).to eq(nil)
      expect((4..2).bsearch { -1 }).to eq(nil)
    end

    it "returns enumerator when block not passed" do
      expect((0...3).bsearch.kind_of?(Enumerator)).to eq(true)
    end
  end

  context "with Float values" do
    context "with a block returning true or false" do
      it "returns nil if the block returns false for every element" do
        expect((0.1...2.3).bsearch { |x| x > 3 }).to be_nil
      end

      it "returns nil if the block returns nil for every element" do
        expect((-0.0..2.3).bsearch { |x| nil }).to be_nil
      end

      it "returns minimum element if the block returns true for every element" do
        expect((-0.2..4.8).bsearch { |x| x < 5 }).to eq(-0.2)
      end

      it "returns the smallest element for which block returns true" do
        expect((0..4.2).bsearch { |x| x >= 2 }).to eq(2)
        expect((-1.2..4.3).bsearch { |x| x >= 1 }).to eq(1)
      end

      it "returns a boundary element if appropriate" do
        expect((1.0..3.0).bsearch { |x| x >= 3.0 }).to eq(3.0)
        expect((1.0...3.0).bsearch { |x| x >= 3.0.prev_float }).to eq(3.0.prev_float)
        expect((1.0..3.0).bsearch { |x| x >= 1.0 }).to eq(1.0)
        expect((1.0...3.0).bsearch { |x| x >= 1.0 }).to eq(1.0)
      end

      it "works with infinity bounds" do
        inf = Float::INFINITY
        expect((0..inf).bsearch { |x| x == inf }).to eq(inf)
        expect((0...inf).bsearch { |x| x == inf }).to eq(nil)
        expect((-inf..0).bsearch { |x| x != -inf }).to eq(-Float::MAX)
        expect((-inf...0).bsearch { |x| x != -inf }).to eq(-Float::MAX)
        expect((inf..inf).bsearch { |x| true }).to eq(inf)
        expect((inf...inf).bsearch { |x| true }).to eq(nil)
        expect((-inf..-inf).bsearch { |x| true }).to eq(-inf)
        expect((-inf...-inf).bsearch { |x| true }).to eq(nil)
        expect((inf..0).bsearch { true }).to eq(nil)
        expect((inf...0).bsearch { true }).to eq(nil)
        expect((0..-inf).bsearch { true }).to eq(nil)
        expect((0...-inf).bsearch { true }).to eq(nil)
        expect((inf..-inf).bsearch { true }).to eq(nil)
        expect((inf...-inf).bsearch { true }).to eq(nil)
        expect((0..inf).bsearch { |x| x >= 3 }).to eq(3.0)
        expect((0...inf).bsearch { |x| x >= 3 }).to eq(3.0)
        expect((-inf..0).bsearch { |x| x >= -3 }).to eq(-3.0)
        expect((-inf...0).bsearch { |x| x >= -3 }).to eq(-3.0)
        expect((-inf..inf).bsearch { |x| x >= 3 }).to eq(3.0)
        expect((-inf...inf).bsearch { |x| x >= 3 }).to eq(3.0)
        expect((0..inf).bsearch { |x| x >= Float::MAX }).to eq(Float::MAX)
        expect((0...inf).bsearch { |x| x >= Float::MAX }).to eq(Float::MAX)
      end
    end

    context "with a block returning negative, zero, positive numbers" do
      it "returns nil if the block returns less than zero for every element" do
        expect((-2.0..3.2).bsearch { |x| x <=> 5 }).to be_nil
      end

      it "returns nil if the block returns greater than zero for every element" do
        expect((0.3..3.0).bsearch { |x| x <=> -1 }).to be_nil
      end

      it "returns nil if the block never returns zero" do
        expect((0.2..2.3).bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
      end

      it "accepts (+/-)Float::INFINITY from the block" do
        expect((0.1..4.5).bsearch { |x| Float::INFINITY }).to be_nil
        expect((-5.0..4.0).bsearch { |x| -Float::INFINITY }).to be_nil
      end

      it "returns an element at an index for which block returns 0.0" do
        result = (0.0..4.0).bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 }
        expect(result).to eq(2)
      end

      it "returns an element at an index for which block returns 0" do
        result = (0.1..4.9).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }
        expect(result).to be >= 1
        expect(result).to be <= 3
      end

      it "returns an element at an index for which block returns 0 (small numbers)" do
        result = (0.1..0.3).bsearch { |x| x < 0.1 ? 1 : x > 0.3 ? -1 : 0 }
        expect(result).to be >= 0.1
        expect(result).to be <= 0.3
      end

      it "returns a boundary element if appropriate" do
        expect((1.0..3.0).bsearch { |x| 3.0 - x }).to eq(3.0)
        expect((1.0...3.0).bsearch { |x| 3.0.prev_float - x }).to eq(3.0.prev_float)
        expect((1.0..3.0).bsearch { |x| 1.0 - x }).to eq(1.0)
        expect((1.0...3.0).bsearch { |x| 1.0 - x }).to eq(1.0)
      end

      it "works with infinity bounds" do
        inf = Float::INFINITY
        expect((0..inf).bsearch { |x| x == inf ? 0 : 1 }).to eq(inf)
        expect((0...inf).bsearch { |x| x == inf ? 0 : 1 }).to eq(nil)
        expect((-inf...0).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
        expect((-inf..0).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
        expect((inf..inf).bsearch { 0 }).to eq(inf)
        expect((inf...inf).bsearch { 0 }).to eq(nil)
        expect((-inf..-inf).bsearch { 0 }).to eq(-inf)
        expect((-inf...-inf).bsearch { 0 }).to eq(nil)
        expect((inf..0).bsearch { 0 }).to eq(nil)
        expect((inf...0).bsearch { 0 }).to eq(nil)
        expect((0..-inf).bsearch { 0 }).to eq(nil)
        expect((0...-inf).bsearch { 0 }).to eq(nil)
        expect((inf..-inf).bsearch { 0 }).to eq(nil)
        expect((inf...-inf).bsearch { 0 }).to eq(nil)
        expect((-inf..inf).bsearch { |x| 3 - x }).to eq(3.0)
        expect((-inf...inf).bsearch { |x| 3 - x }).to eq(3.0)
        expect((0...inf).bsearch { |x| x >= Float::MAX ? 0 : 1 }).to eq(Float::MAX)
      end
    end

    it "returns enumerator when block not passed" do
      expect((0.1...2.3).bsearch.kind_of?(Enumerator)).to eq(true)
    end
  end

  context "with endless ranges and Integer values" do
    context "with a block returning true or false" do
      it "returns minimum element if the block returns true for every element" do
        expect(eval("(-2..)").bsearch { |x| true }).to eq(-2)
      end

      it "returns the smallest element for which block returns true" do
        expect(eval("(0..)").bsearch { |x| x >= 2 }).to eq(2)
        expect(eval("(-1..)").bsearch { |x| x >= 1 }).to eq(1)
      end
    end

    context "with a block returning negative, zero, positive numbers" do
      it "returns nil if the block returns less than zero for every element" do
        expect(eval("(0..)").bsearch { |x| -1 }).to be_nil
      end

      it "returns nil if the block never returns zero" do
        expect(eval("(0..)").bsearch { |x| x > 5 ? -1 : 1 }).to be_nil
      end

      it "accepts -Float::INFINITY from the block" do
        expect(eval("(0..)").bsearch { |x| -Float::INFINITY }).to be_nil
      end

      it "returns an element at an index for which block returns 0.0" do
        result = eval("(0..)").bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 }
        expect(result).to eq(2)
      end

      it "returns an element at an index for which block returns 0" do
        result = eval("(0..)").bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }
        expect([1, 2, 3]).to include(result)
      end
    end

    it "returns enumerator when block not passed" do
      expect(eval("(-2..)").bsearch.kind_of?(Enumerator)).to eq(true)
    end
  end

  context "with endless ranges and Float values" do
    context "with a block returning true or false" do
      it "returns nil if the block returns false for every element" do
        expect(eval("(0.1..)").bsearch { |x| x < 0.0 }).to be_nil
        expect(eval("(0.1...)").bsearch { |x| x < 0.0 }).to be_nil
      end

      it "returns nil if the block returns nil for every element" do
        expect(eval("(-0.0..)").bsearch { |x| nil }).to be_nil
        expect(eval("(-0.0...)").bsearch { |x| nil }).to be_nil
      end

      it "returns minimum element if the block returns true for every element" do
        expect(eval("(-0.2..)").bsearch { |x| true }).to eq(-0.2)
        expect(eval("(-0.2...)").bsearch { |x| true }).to eq(-0.2)
      end

      it "returns the smallest element for which block returns true" do
        expect(eval("(0..)").bsearch { |x| x >= 2 }).to eq(2)
        expect(eval("(-1.2..)").bsearch { |x| x >= 1 }).to eq(1)
      end

      it "works with infinity bounds" do
        inf = Float::INFINITY
        expect(eval("(inf..)").bsearch { |x| true }).to eq(inf)
        expect(eval("(inf...)").bsearch { |x| true }).to eq(nil)
        expect(eval("(-inf..)").bsearch { |x| true }).to eq(-inf)
        expect(eval("(-inf...)").bsearch { |x| true }).to eq(-inf)
      end
    end

    context "with a block returning negative, zero, positive numbers" do
      it "returns nil if the block returns less than zero for every element" do
        expect(eval("(-2.0..)").bsearch { |x| -1 }).to be_nil
        expect(eval("(-2.0...)").bsearch { |x| -1 }).to be_nil
      end

      it "returns nil if the block returns greater than zero for every element" do
        expect(eval("(0.3..)").bsearch { |x| 1 }).to be_nil
        expect(eval("(0.3...)").bsearch { |x| 1 }).to be_nil
      end

      it "returns nil if the block never returns zero" do
        expect(eval("(0.2..)").bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
      end

      it "accepts (+/-)Float::INFINITY from the block" do
        expect(eval("(0.1..)").bsearch { |x| Float::INFINITY }).to be_nil
        expect(eval("(-5.0..)").bsearch { |x| -Float::INFINITY }).to be_nil
      end

      it "returns an element at an index for which block returns 0.0" do
        result = eval("(0.0..)").bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 }
        expect(result).to eq(2)
      end

      it "returns an element at an index for which block returns 0" do
        result = eval("(0.1..)").bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }
        expect(result).to be >= 1
        expect(result).to be <= 3
      end

      it "works with infinity bounds" do
        inf = Float::INFINITY
        expect(eval("(inf..)").bsearch { |x| 1 }).to eq(nil)
        expect(eval("(inf...)").bsearch { |x| 1 }).to eq(nil)
        expect(eval("(inf..)").bsearch { |x| x == inf ? 0 : 1 }).to eq(inf)
        expect(eval("(inf...)").bsearch { |x| x == inf ? 0 : 1 }).to eq(nil)
        expect(eval("(-inf..)").bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
        expect(eval("(-inf...)").bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
        expect(eval("(-inf..)").bsearch { |x| 3 - x }).to eq(3)
        expect(eval("(-inf...)").bsearch { |x| 3 - x }).to eq(3)
        expect(eval("(0.0...)").bsearch { 0 }).not_to eq(inf)
      end
    end

    it "returns enumerator when block not passed" do
      expect(eval("(0.1..)").bsearch.kind_of?(Enumerator)).to eq(true)
    end
  end

  context "with beginless ranges and Integer values" do
    context "with a block returning true or false" do
      it "returns the smallest element for which block returns true" do
        expect((..10).bsearch { |x| x >= 2 }).to eq(2)
        expect((...-1).bsearch { |x| x >= -10 }).to eq(-10)
      end
    end

    context "with a block returning negative, zero, positive numbers" do
      it "returns nil if the block returns greater than zero for every element" do
        expect((..0).bsearch { |x| 1 }).to be_nil
      end

      it "returns nil if the block never returns zero" do
        expect((..0).bsearch { |x| x > 5 ? -1 : 1 }).to be_nil
      end

      it "accepts Float::INFINITY from the block" do
        expect((..0).bsearch { |x| Float::INFINITY }).to be_nil
      end

      it "returns an element at an index for which block returns 0.0" do
        result = (..10).bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 }
        expect(result).to eq(2)
      end

      it "returns an element at an index for which block returns 0" do
        result = (...10).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }
        expect([1, 2, 3]).to include(result)
      end
    end

    it "returns enumerator when block not passed" do
      expect((..10).bsearch.kind_of?(Enumerator)).to eq(true)
    end
  end

  context "with beginless ranges and Float values" do
    context "with a block returning true or false" do
      it "returns nil if the block returns true for every element" do
        expect((..-0.1).bsearch { |x| x > 0.0 }).to be_nil
        expect((...-0.1).bsearch { |x| x > 0.0 }).to be_nil
      end

      it "returns nil if the block returns nil for every element" do
        expect((..-0.1).bsearch { |x| nil }).to be_nil
        expect((...-0.1).bsearch { |x| nil }).to be_nil
      end

      it "returns the smallest element for which block returns true" do
        expect((..10).bsearch { |x| x >= 2 }).to eq(2)
        expect((..10).bsearch { |x| x >= 1 }).to eq(1)
      end

      it "works with infinity bounds" do
        inf = Float::INFINITY
        expect((..inf).bsearch { |x| true }).to eq(-inf)
        expect((...inf).bsearch { |x| true }).to eq(-inf)
        expect((..-inf).bsearch { |x| true }).to eq(-inf)
        expect((...-inf).bsearch { |x| true }).to eq(nil)
      end
    end

    context "with a block returning negative, zero, positive numbers" do
      it "returns nil if the block returns less than zero for every element" do
        expect((..5.0).bsearch { |x| -1 }).to be_nil
        expect((...5.0).bsearch { |x| -1 }).to be_nil
      end

      it "returns nil if the block returns greater than zero for every element" do
        expect((..1.1).bsearch { |x| 1 }).to be_nil
        expect((...1.1).bsearch { |x| 1 }).to be_nil
      end

      it "returns nil if the block never returns zero" do
        expect((..6.3).bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
      end

      it "accepts (+/-)Float::INFINITY from the block" do
        expect((..5.0).bsearch { |x| Float::INFINITY }).to be_nil
        expect((..7.0).bsearch { |x| -Float::INFINITY }).to be_nil
      end

      it "returns an element at an index for which block returns 0.0" do
        result = (..8.0).bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 }
        expect(result).to eq(2)
      end

      it "returns an element at an index for which block returns 0" do
        result = (..8.0).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }
        expect(result).to be >= 1
        expect(result).to be <= 3
      end

      it "works with infinity bounds" do
        inf = Float::INFINITY
        expect((..-inf).bsearch { |x| 1 }).to eq(nil)
        expect((...-inf).bsearch { |x| 1 }).to eq(nil)
        expect((..inf).bsearch { |x| x == inf ? 0 : 1 }).to eq(inf)
        expect((...inf).bsearch { |x| x == inf ? 0 : 1 }).to eq(nil)
        expect((..-inf).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
        expect((...-inf).bsearch { |x| x == -inf ? 0 : -1 }).to eq(nil)
        expect((..inf).bsearch { |x| 3 - x }).to eq(3)
        expect((...inf).bsearch { |x| 3 - x }).to eq(3)
      end
    end

    it "returns enumerator when block not passed" do
      expect((..-0.1).bsearch.kind_of?(Enumerator)).to eq(true)
    end
  end
end
