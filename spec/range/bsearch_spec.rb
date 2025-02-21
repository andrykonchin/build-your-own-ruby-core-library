require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#bsearch' do
  context 'Integer range' do
    context 'Find-Minimum Mode (block returns true/false)' do
      it 'returns the leftmost element for which a block returns true' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| n >= 4 }).to eq(4)
      end

      it 'returns nil if element not found' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| n >= 10 }).to be_nil
      end

      it 'can return self.begin' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| n >= -1 }).to eq(0)
      end

      it 'can return self.end' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| n >= 6 }).to eq(6)
      end

      it 'ignores self.end if excluded end' do
        range = Range.new(0, 6, true)
        expect(range.bsearch { |n| n >= 6 }).to be_nil
      end

      it 'returns nil for empty ranges' do
        range = Range.new(0, 0, true)
        expect(range.bsearch { |n| n == 0 }).to be_nil
      end

      it 'supports Float::INFINITY as a boundary' do
        range = Range.new(0, Float::INFINITY)
        expect(range.bsearch { |n| n >= 4 }).to eq(4)

        range = Range.new(-Float::INFINITY, 6)
        expect(range.bsearch { |n| n >= 4 }).to eq(4)

        range = Range.new(-Float::INFINITY, Float::INFINITY)
        expect(range.bsearch { |n| n >= 4 }).to eq(4)
      end

      it 'threats nil returned from a block as false' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| n >= 4 ? true : nil }).to eq(4)
      end

      it 'supports beginingless ranges' do
        range = Range.new(nil, 6)
        expect(range.bsearch { |n| n >= 4 }).to eq(4)
      end

      it 'supports endless ranges' do
        range = Range.new(0, nil)
        expect(range.bsearch { |n| n >= 4 }).to eq(4)
      end

      it 'returns nil if backward range' do
        range = Range.new(6, 0)
        expect(range.bsearch { |n| n >= 4 }).to be_nil
      end
    end

    context 'Find-Any Mode (block returns Numeric values)' do
      it 'returns the leftmost element for which a block returns 0' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| 4 <=> n }).to eq(4)
      end

      it 'returns nil if element not found' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| -6 <=> n }).to be_nil
      end

      it 'can return self.begin' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| 0 <=> n }).to eq(0)
      end

      it 'can return self.end' do
        range = Range.new(0, 6)
        expect(range.bsearch { |n| 6 <=> n }).to eq(6)
      end

      it 'ignores self.end if excluded end' do
        range = Range.new(0, 6, true)
        expect(range.bsearch { |n| 6 <=> n }).to be_nil
      end

      it 'returns any element for which a block returns 0 if there are a few such elements' do
        result = Range.new(0, 4).bsearch { |x|
          if x < 1
            1
          elsif x > 3
            -1
          else
            0
          end
        }
        expect(result).to(satisfy { |v| [1, 2, 3].include?(v) })
      end

      it 'returns nil for empty ranges' do
        range = Range.new(0, 0, true)
        expect(range.bsearch { |n| 0 <=> n }).to be_nil
      end

      it 'supports Float::INFINITY as a boundary' do
        range = Range.new(0, Float::INFINITY)
        expect(range.bsearch { |n| 4 <=> n }).to eq(4)

        range = Range.new(-Float::INFINITY, 6)
        expect(range.bsearch { |n| 4 <=> n }).to eq(4)

        range = Range.new(-Float::INFINITY, Float::INFINITY)
        expect(range.bsearch { |n| 4 <=> n }).to eq(4)
      end

      it 'supports beginingless ranges' do
        range = Range.new(nil, 6)
        expect(range.bsearch { |n| 4 <=> n }).to eq(4)
      end

      it 'supports endless ranges' do
        range = Range.new(0, nil)
        expect(range.bsearch { |n| 4 <=> n }).to eq(4)
      end

      it 'returns nil if backward range' do
        range = Range.new(6, 0)
        expect(range.bsearch { |n| n <=> 4 }).to be_nil

        range = Range.new(6, 0)
        expect(range.bsearch { |n| n <=> 6 }).to be_nil

        range = Range.new(6, 0)
        expect(range.bsearch { |n| n <=> 0 }).to be_nil
      end
    end

    it 'raises TypeError if block returns value other than Numeric, true, false or nil' do
      range = Range.new(0, 6)

      expect {
        range.bsearch { [] }
      }.to raise_error(TypeError, 'wrong argument type Array (must be numeric, true, false or nil)')
    end

    it 'returns enumerator when block not passed' do
      range = Range.new(0, 6)

      expect(range.bsearch).to be_an_instance_of(Enumerator)
      expect(range.bsearch.each { |n| 4 <=> n }).to eq(4)
    end

    describe 'returned Enumerator' do
      it 'size returns nil' do
        enum = Range.new(0, 6).bsearch
        expect(enum.size).to be_nil
      end
    end
  end

  context 'Float range' do
    before do
      skip "it isn't trivial to keep precision with Float values"
    end

    context 'with Float values' do
      context 'with a block returning true or false' do
        it 'returns nil if the block returns false for every element' do
          expect(Range.new(0.1, 2.3, true).bsearch { |x| x > 3 }).to be_nil
        end

        it 'returns nil if the block returns nil for every element' do
          expect(Range.new(-0.0, 2.3).bsearch { |_x| nil }).to be_nil
        end

        it 'returns minimum element if the block returns true for every element' do
          expect(Range.new(-0.2, 4.8).bsearch { |x| x < 5 }).to eq(-0.2)
        end

        it 'returns the smallest element for which block returns true' do
          expect(Range.new(0, 4.2).bsearch { |x| x >= 2 }).to eq(2)
          expect(Range.new(-1.2, 4.3).bsearch { |x| x >= 1 }).to eq(1)
        end

        it 'returns a boundary element if appropriate' do
          expect(Range.new(1.0, 3.0).bsearch { |x| x >= 3.0 }).to eq(3.0)
          expect(Range.new(1.0, 3.0, true).bsearch { |x| x >= 3.0.prev_float }).to eq(3.0.prev_float)
          expect(Range.new(1.0, 3.0).bsearch { |x| x >= 1.0 }).to eq(1.0)
          expect(Range.new(1.0, 3.0, true).bsearch { |x| x >= 1.0 }).to eq(1.0)
        end

        it 'works with infinity bounds' do
          inf = Float::INFINITY
          expect(Range.new(0, inf).bsearch { |x| x == inf }).to eq(inf)
          expect(Range.new(0, inf, true).bsearch { |x| x == inf }).to be_nil
          expect(Range.new(-inf, 0).bsearch { |x| x != -inf }).to eq(-Float::MAX)
          expect(Range.new(-inf, 0, true).bsearch { |x| x != -inf }).to eq(-Float::MAX)
          expect(Range.new(inf, inf).bsearch { |_x| true }).to eq(inf)
          expect(Range.new(inf, inf, true).bsearch { |_x| true }).to be_nil
          expect(Range.new(-inf, -inf).bsearch { |_x| true }).to eq(-inf)
          expect(Range.new(-inf, -inf, true).bsearch { |_x| true }).to be_nil
          expect(Range.new(inf, 0).bsearch { true }).to be_nil
          expect(Range.new(inf, 0, true).bsearch { true }).to be_nil
          expect(Range.new(0, -inf).bsearch { true }).to be_nil
          expect(Range.new(0, -inf, true).bsearch { true }).to be_nil
          expect(Range.new(inf, -inf).bsearch { true }).to be_nil
          expect(Range.new(inf, -inf, true).bsearch { true }).to be_nil
          expect(Range.new(0, inf).bsearch { |x| x >= 3 }).to eq(3.0)
          expect(Range.new(0, inf, true).bsearch { |x| x >= 3 }).to eq(3.0)
          expect(Range.new(-inf, 0).bsearch { |x| x >= -3 }).to eq(-3.0)
          expect(Range.new(-inf, 0, true).bsearch { |x| x >= -3 }).to eq(-3.0)
          expect(Range.new(-inf, inf).bsearch { |x| x >= 3 }).to eq(3.0)
          expect(Range.new(-inf, inf, true).bsearch { |x| x >= 3 }).to eq(3.0)
          expect(Range.new(0, inf).bsearch { |x| x >= Float::MAX }).to eq(Float::MAX)
          expect(Range.new(0, inf, true).bsearch { |x| x >= Float::MAX }).to eq(Float::MAX)
        end
      end

      context 'with a block returning negative, zero, positive numbers' do
        it 'returns nil if the block returns less than zero for every element' do
          expect(Range.new(-2.0, 3.2).bsearch { |x| x <=> 5 }).to be_nil
        end

        it 'returns nil if the block returns greater than zero for every element' do
          expect(Range.new(0.3, 3.0).bsearch { |x| x <=> -1 }).to be_nil
        end

        it 'returns nil if the block never returns zero' do
          expect(Range.new(0.2, 2.3).bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
        end

        it 'accepts (+/-)Float::INFINITY from the block' do
          expect(Range.new(0.1, 4.5).bsearch { |_x| Float::INFINITY }).to be_nil
          expect(Range.new(-5.0, 4.0).bsearch { |_x| -Float::INFINITY }).to be_nil
        end

        it 'returns an element at an index for which block returns 0.0' do
          result = Range.new(0.0, 4.0).bsearch { |x|
            if x < 2
              1.0
            else
              x > 2 ? -1.0 : 0.0
            end
          }
          expect(result).to eq(2)
        end

        it 'returns an element at an index for which block returns 0' do
          result = Range.new(0.1, 4.9).bsearch { |x|
            if x < 1
              1
            else
              x > 3 ? -1 : 0
            end
          }
          expect(result).to be >= 1
          expect(result).to be <= 3
        end

        it 'returns an element at an index for which block returns 0 (small numbers)' do
          result = Range.new(0.1, 0.3).bsearch { |x|
            if x < 0.1
              1
            else
              x > 0.3 ? -1 : 0
            end
          }
          expect(result).to be >= 0.1
          expect(result).to be <= 0.3
        end

        it 'returns a boundary element if appropriate' do
          expect(Range.new(1.0, 3.0).bsearch { |x| 3.0 - x }).to eq(3.0)
          expect(Range.new(1.0, 3.0, true).bsearch { |x| 3.0.prev_float - x }).to eq(3.0.prev_float)
          expect(Range.new(1.0, 3.0).bsearch { |x| 1.0 - x }).to eq(1.0)
          expect(Range.new(1.0, 3.0, true).bsearch { |x| 1.0 - x }).to eq(1.0)
        end

        it 'works with infinity bounds' do
          inf = Float::INFINITY
          expect(Range.new(0, inf).bsearch { |x| x == inf ? 0 : 1 }).to eq(inf)
          expect(Range.new(0, inf, true).bsearch { |x| x == inf ? 0 : 1 }).to be_nil
          expect(Range.new(-inf, 0, true).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
          expect(Range.new(-inf, 0).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
          expect(Range.new(inf, inf).bsearch { 0 }).to eq(inf)
          expect(Range.new(inf, inf, true).bsearch { 0 }).to be_nil
          expect(Range.new(-inf, -inf).bsearch { 0 }).to eq(-inf)
          expect(Range.new(-inf, -inf, true).bsearch { 0 }).to be_nil
          expect(Range.new(inf, 0).bsearch { 0 }).to be_nil
          expect(Range.new(inf, 0, true).bsearch { 0 }).to be_nil
          expect(Range.new(0, -inf).bsearch { 0 }).to be_nil
          expect(Range.new(0, -inf, true).bsearch { 0 }).to be_nil
          expect(Range.new(inf, -inf).bsearch { 0 }).to be_nil
          expect(Range.new(inf, -inf, true).bsearch { 0 }).to be_nil
          expect(Range.new(-inf, inf).bsearch { |x| 3 - x }).to eq(3.0)
          expect(Range.new(-inf, inf, true).bsearch { |x| 3 - x }).to eq(3.0)
          expect(Range.new(0, inf, true).bsearch { |x| x >= Float::MAX ? 0 : 1 }).to eq(Float::MAX)
        end
      end

      it 'returns enumerator when block not passed' do
        expect(Range.new(0.1, 2.3, true).bsearch.is_a?(Enumerator)).to be(true)
      end
    end

    context 'with endless ranges and Float values' do
      context 'with a block returning true or false' do
        it 'returns nil if the block returns false for every element' do
          expect(Range.new(0.1, nil).bsearch { |x| x < 0.0 }).to be_nil
          expect(Range.new(0.1, nil, true).bsearch { |x| x < 0.0 }).to be_nil
        end

        it 'returns nil if the block returns nil for every element' do
          expect(Range.new(-0.0, nil).bsearch { |_x| nil }).to be_nil
          expect(Range.new(-0.0, nil, true).bsearch { |_x| nil }).to be_nil
        end

        it 'returns minimum element if the block returns true for every element' do
          expect(Range.new(-0.2, nil).bsearch { |_x| true }).to eq(-0.2)
          expect(Range.new(-0.2, nil, true).bsearch { |_x| true }).to eq(-0.2)
        end

        it 'returns the smallest element for which block returns true' do
          expect(Range.new(0, nil).bsearch { |x| x >= 2 }).to eq(2)
          expect(Range.new(-1.2, nil).bsearch { |x| x >= 1 }).to eq(1)
        end

        it 'works with infinity bounds' do
          inf = Float::INFINITY
          expect(Range.new(inf, nil).bsearch { |_x| true }).to eq(inf)
          expect(Range.new(inf, nil, true).bsearch { |_x| true }).to be_nil
          expect(Range.new(-inf, nil).bsearch { |_x| true }).to eq(-inf)
          expect(Range.new(-inf, nil, true).bsearch { |_x| true }).to eq(-inf)
        end
      end

      context 'with a block returning negative, zero, positive numbers' do
        it 'returns nil if the block returns less than zero for every element' do
          expect(Range.new(-2.0, nil).bsearch { |_x| -1 }).to be_nil
          expect(Range.new(-2.0, nil, true).bsearch { |_x| -1 }).to be_nil
        end

        it 'returns nil if the block returns greater than zero for every element' do
          expect(Range.new(0.3, nil).bsearch { |_x| 1 }).to be_nil
          expect(Range.new(0.3, nil, true).bsearch { |_x| 1 }).to be_nil
        end

        it 'returns nil if the block never returns zero' do
          expect(Range.new(0.2, nil).bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
        end

        it 'accepts (+/-)Float::INFINITY from the block' do
          expect(Range.new(0.1, nil).bsearch { |_x| Float::INFINITY }).to be_nil
          expect(Range.new(-5.0, nil).bsearch { |_x| -Float::INFINITY }).to be_nil
        end

        it 'returns an element at an index for which block returns 0.0' do
          result = Range.new(0.0, nil).bsearch { |x|
            if x < 2
              1.0
            else
              x > 2 ? -1.0 : 0.0
            end
          }
          expect(result).to eq(2)
        end

        it 'returns an element at an index for which block returns 0' do
          result = Range.new(0.1, nil).bsearch { |x|
            if x < 1
              1
            else
              x > 3 ? -1 : 0
            end
          }
          expect(result).to be >= 1
          expect(result).to be <= 3
        end

        it 'works with infinity bounds' do
          inf = Float::INFINITY
          expect(Range.new(inf, nil).bsearch { |_x| 1 }).to be_nil
          expect(Range.new(inf, nil, true).bsearch { |_x| 1 }).to be_nil
          expect(Range.new(inf, nil).bsearch { |x| x == inf ? 0 : 1 }).to eq(inf)
          expect(Range.new(inf, nil, true).bsearch { |x| x == inf ? 0 : 1 }).to be_nil
          expect(Range.new(-inf, nil).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
          expect(Range.new(-inf, nil, true).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
          expect(Range.new(-inf, nil).bsearch { |x| 3 - x }).to eq(3)
          expect(Range.new(-inf, nil, true).bsearch { |x| 3 - x }).to eq(3)
          expect(Range.new(0.0, nil, true).bsearch { 0 }).not_to eq(inf)
        end
      end

      it 'returns enumerator when block not passed' do
        expect(Range.new(0.1, nil).bsearch.is_a?(Enumerator)).to be(true)
      end
    end

    context 'with beginless ranges and Float values' do
      context 'with a block returning true or false' do
        it 'returns nil if the block returns true for every element' do
          expect(Range.new(nil, -0.1).bsearch { |x| x > 0.0 }).to be_nil
          expect(Range.new(nil, -0.1, true).bsearch { |x| x > 0.0 }).to be_nil
        end

        it 'returns nil if the block returns nil for every element' do
          expect(Range.new(nil, -0.1).bsearch { |_x| nil }).to be_nil
          expect(Range.new(nil, -0.1, true).bsearch { |_x| nil }).to be_nil
        end

        it 'returns the smallest element for which block returns true' do
          expect(Range.new(nil, 10).bsearch { |x| x >= 2 }).to eq(2)
          expect(Range.new(nil, 10).bsearch { |x| x >= 1 }).to eq(1)
        end

        it 'works with infinity bounds' do
          inf = Float::INFINITY
          expect(Range.new(nil, inf).bsearch { |_x| true }).to eq(-inf)
          expect(Range.new(nil, inf, true).bsearch { |_x| true }).to eq(-inf)
          expect(Range.new(nil, -inf).bsearch { |_x| true }).to eq(-inf)
          expect(Range.new(nil, -inf, true).bsearch { |_x| true }).to be_nil
        end
      end

      context 'with a block returning negative, zero, positive numbers' do
        it 'returns nil if the block returns less than zero for every element' do
          expect(Range.new(nil, 5.0).bsearch { |_x| -1 }).to be_nil
          expect(Range.new(nil, 5.0, nil).bsearch { |_x| -1 }).to be_nil
        end

        it 'returns nil if the block returns greater than zero for every element' do
          expect(Range.new(nil, 1.1).bsearch { |_x| 1 }).to be_nil
          expect(Range.new(nil, 1.1, true).bsearch { |_x| 1 }).to be_nil
        end

        it 'returns nil if the block never returns zero' do
          expect(Range.new(nil, 6.3).bsearch { |x| x < 2 ? 1 : -1 }).to be_nil
        end

        it 'accepts (+/-)Float::INFINITY from the block' do
          expect(Range.new(nil, 5.0).bsearch { |_x| Float::INFINITY }).to be_nil
          expect(Range.new(nil, 7.0).bsearch { |_x| -Float::INFINITY }).to be_nil
        end

        it 'returns an element at an index for which block returns 0.0' do
          result = Range.new(nil, 8.0).bsearch { |x|
            if x < 2
              1.0
            else
              x > 2 ? -1.0 : 0.0
            end
          }
          expect(result).to eq(2)
        end

        it 'returns an element at an index for which block returns 0' do
          result = Range.new(nil, 8.0).bsearch { |x|
            if x < 1
              1
            else
              x > 3 ? -1 : 0
            end
          }
          expect(result).to be >= 1
          expect(result).to be <= 3
        end

        it 'works with infinity bounds' do
          inf = Float::INFINITY
          expect(Range.new(nil, -inf).bsearch { |_x| 1 }).to be_nil
          expect(Range.new(nil, -inf, true).bsearch { |_x| 1 }).to be_nil
          expect(Range.new(nil, inf).bsearch { |x| x == inf ? 0 : 1 }).to eq(inf)
          expect(Range.new(nil, inf, true).bsearch { |x| x == inf ? 0 : 1 }).to be_nil
          expect(Range.new(nil, -inf).bsearch { |x| x == -inf ? 0 : -1 }).to eq(-inf)
          expect(Range.new(nil, -inf, true).bsearch { |x| x == -inf ? 0 : -1 }).to be_nil
          expect(Range.new(nil, inf).bsearch { |x| 3 - x }).to eq(3)
          expect(Range.new(nil, inf, true).bsearch { |x| 3 - x }).to eq(3)
        end
      end

      it 'returns enumerator when block not passed' do
        expect(Range.new(nil, -0.1).bsearch.is_a?(Enumerator)).to be(true)
      end
    end
  end

  context 'non-Integer/-Float range' do
    it 'raises TypeError' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))

      expect {
        range.bsearch { true }
      }.to raise_error(TypeError, "can't do binary search for RangeSpecs::Element")
    end

    it 'raises TypeError for nil..nil' do
      range = Range.new(nil, nil)

      expect {
        range.bsearch { [] }
      }.to raise_error(TypeError, "can't do binary search for NilClass")
    end

    it 'raises TypeError when block not passed' do
      range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))

      expect {
        range.bsearch
      }.to raise_error(TypeError, "can't do binary search for RangeSpecs::Element")
    end
  end
end
