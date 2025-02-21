require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#minmax' do
  before(:each) do
    @x = double('x')
    @y = double('y')

    expect(@x).to receive(:<=>).with(@y).at_least(:once).and_return(-1) # x < y
    expect(@x).to receive(:<=>).with(@x).at_least(:once).and_return(0) # x == x
    expect(@y).to receive(:<=>).with(@x).at_least(:once).and_return(1) # y > x
    expect(@y).to receive(:<=>).with(@y).at_least(:once).and_return(0) # y == y
  end

  describe 'on an inclusive range' do
    it 'should raise RangeError on an endless range without iterating the range' do
      expect(@x).not_to receive(:succ)

      range = (@x..)

      expect { range.minmax }.to raise_error(RangeError, 'cannot get the maximum of endless range')
    end

    it 'raises RangeError or ArgumentError on a beginless range' do
      range = (..@x)

      expect { range.minmax }.to raise_error(StandardError) { |e|
        if RangeError === e
          # error from #min
          expect { raise e }.to raise_error(RangeError, 'cannot get the minimum of beginless range')
        else
          # error from #max
          expect { raise e }.to raise_error(ArgumentError, 'comparison of NilClass with MockObject failed')
        end
      }
    end

    it 'should return beginning of range if beginning and end are equal without iterating the range' do
      expect(@x).not_to receive(:succ)

      expect((@x..@x).minmax).to eq([@x, @x])
    end

    it 'should return nil pair if beginning is greater than end without iterating the range' do
      expect(@y).not_to receive(:succ)

      expect((@y..@x).minmax).to eq([nil, nil])
    end

    it 'should return the minimum and maximum values for a non-numeric range without iterating the range' do
      expect(@x).not_to receive(:succ)

      expect((@x..@y).minmax).to eq([@x, @y])
    end

    it 'should return the minimum and maximum values for a numeric range' do
      expect((1..3).minmax).to eq([1, 3])
    end

    it 'should return the minimum and maximum values for a numeric range without iterating the range' do
      # We cannot set expectations on integers,
      # so we "prevent" iteration by picking a value that would iterate until the spec times out.
      range_end = Float::INFINITY

      expect((1..range_end).minmax).to eq([1, range_end])
    end

    it 'should return the minimum and maximum values according to the provided block by iterating the range' do
      expect(@x).to receive(:succ).once.and_return(@y)

      expect((@x..@y).minmax { |x, y| - (x <=> y) }).to eq([@y, @x])
    end
  end

  describe 'on an exclusive range' do
    it 'should raise RangeError on an endless range' do
      expect(@x).not_to receive(:succ)
      range = (@x...)

      expect { range.minmax }.to raise_error(RangeError, 'cannot get the maximum of endless range')
    end

    it 'should raise RangeError on a beginless range' do
      range = (...@x)

      expect { range.minmax }.to raise_error(RangeError,
        /cannot get the maximum of beginless range with custom comparison method|cannot get the minimum of beginless range/)
    end

    it 'should return nil pair if beginning and end are equal without iterating the range' do
      expect(@x).not_to receive(:succ)

      expect((@x...@x).minmax).to eq([nil, nil])
    end

    it 'should return nil pair if beginning is greater than end without iterating the range' do
      expect(@y).not_to receive(:succ)

      expect((@y...@x).minmax).to eq([nil, nil])
    end

    it 'should return the minimum and maximum values for a non-numeric range by iterating the range' do
      expect(@x).to receive(:succ).once.and_return(@y)

      expect((@x...@y).minmax).to eq([@x, @x])
    end

    it 'should return the minimum and maximum values for a numeric range' do
      expect((1...3).minmax).to eq([1, 2])
    end

    it 'should return the minimum and maximum values for a numeric range without iterating the range' do
      # We cannot set expectations on integers,
      # so we "prevent" iteration by picking a value that would iterate until the spec times out.
      range_end = bignum_value

      expect((1...range_end).minmax).to eq([1, range_end - 1])
    end

    it 'raises TypeError if the end value is not an integer' do
      range = (0...Float::INFINITY)
      expect { range.minmax }.to raise_error(TypeError, 'cannot exclude non Integer end value')
    end

    it 'should return the minimum and maximum values according to the provided block by iterating the range' do
      expect(@x).to receive(:succ).once.and_return(@y)

      expect((@x...@y).minmax { |x, y| - (x <=> y) }).to eq([@x, @x])
    end
  end
end
