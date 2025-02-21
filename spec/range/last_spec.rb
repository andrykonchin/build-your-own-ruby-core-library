require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#last' do
  it 'returns self.end' do # rubocop:disable RSpec/RepeatedExample
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)

    range = Range.new(a, b, true)
    expect(range.last).to equal(b)
  end

  it 'returns self.end even when end is excluded' do # rubocop:disable RSpec/RepeatedExample
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)

    range = Range.new(a, b, true)
    expect(range.last).to equal(b)
  end

  it 'returns self.end even when self is empty' do
    a = RangeSpecs::Element.new(0)
    range = Range.new(a, a, true)

    expect(range.last).to equal(a)
  end

  it 'returns self.end even when self is backward' do
    a = RangeSpecs::Element.new(0)
    b = RangeSpecs::Element.new(1)

    range = Range.new(b, a)
    expect(range.last).to equal(a)
  end

  it 'returns self.end when beginingless range' do
    a = RangeSpecs::Element.new(1)
    range = Range.new(nil, a)

    expect(range.last).to equal(a)
  end

  it 'returns self.end when a range is not iterable' do
    a = RangeSpecs::WithoutSucc.new(0)
    b = RangeSpecs::WithoutSucc.new(1)

    range = Range.new(a, b)
    expect(range.last).to equal(b)
  end

  it 'raises RangeError if endless range' do
    a = RangeSpecs::WithSucc.new(0)
    range = Range.new(a, nil)

    expect {
      range.last
    }.to raise_error(RangeError, 'cannot get the last element of endless range')
  end

  describe 'given an argument' do
    it 'returns the last n elements in an array' do
      range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))

      expect(range.last(2)).to eq(
        [
          RangeSpecs::WithSucc.new(3),
          RangeSpecs::WithSucc.new(4)
        ]
      )
    end

    it "doesn't yield self.end when end is excluded" do
      range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)

      expect(range.last(4)).to eq(
        [
          RangeSpecs::WithSucc.new(1),
          RangeSpecs::WithSucc.new(2),
          RangeSpecs::WithSucc.new(3)
        ]
      )
    end

    it 'returns an empty array when a range is empty' do
      expect(Range.new(0, 0, true).last(2)).to eq([])
    end

    it 'returns an empty array when a range is backward' do
      range = Range.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(0))
      expect(range.last(2)).to eq([])
    end

    it 'returns an empty array when n is zero' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
      expect(range.last(0)).to eq([])
    end

    it 'raises RangeError when endless range' do
      range = Range.new(RangeSpecs::WithSucc.new(0), nil)

      expect {
        range.last(2)
      }.to raise_error(RangeError, 'cannot get the last element of endless range')
    end

    it 'raises TypeError if a range is not iterable' do
      range = Range.new(RangeSpecs::WithoutSucc.new(0), RangeSpecs::WithoutSucc.new(1))

      expect {
        range.last(2)
      }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")
    end

    it 'raises an ArgumentError when an argument is negative' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

      expect {
        range.last(-1)
      }.to raise_error(ArgumentError, 'negative array size')
    end

    it 'raises a RangeError when passed a Bignum' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

      expect {
        range.last(bignum_value)
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    it 'returns all elements in the range when n exceeds the number of elements' do
      range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

      expect(range.last(100)).to eq(
        [
          RangeSpecs::WithSucc.new(0),
          RangeSpecs::WithSucc.new(1)
        ]
      )
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
        n = double('n', to_int: 2)

        expect(range.last(n)).to eq(
          [
            RangeSpecs::WithSucc.new(0),
            RangeSpecs::WithSucc.new(1)
          ]
        )
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))

        expect { range.last(nil) }.to raise_error(TypeError, 'no implicit conversion from nil to integer')
        expect { range.last('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        range = Range.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(1))
        n = double('n', to_int: 'a')

        expect {
          range.last(n)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end
end
