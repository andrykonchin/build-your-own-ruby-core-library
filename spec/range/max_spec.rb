# Copyright (c) 2025 Andrii Konchyn
# Copyright (c) 2008 Engine Yard, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#max' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns self.end' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.max).to eq(RangeSpecs::WithSucc.new(4))
  end

  it 'returns nil for empty range' do
    range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0), true)
    expect(range.max).to be_nil
  end

  it 'returns nil for backward range' do
    range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
    expect(range.max).to be_nil
  end

  it 'returns self.end for beginingless range and non-Numeric self.end' do
    range = described_class.new(nil, RangeSpecs::WithSucc.new(4))
    expect(range.max).to eq(RangeSpecs::WithSucc.new(4))
  end

  it 'raises RangeError for beginingless range with excluded end and non-Numeric self.end' do
    range = described_class.new(nil, RangeSpecs::WithSucc.new(4), true)

    expect {
      range.max
    }.to raise_error(RangeError, 'cannot get the maximum of beginless range with custom comparison method')
  end

  it 'returns self.end for beginingless range and Numeric non-Integer self.end' do
    range = described_class.new(nil, RangeSpecs::Number.new(4))
    expect(range.max).to eq(RangeSpecs::Number.new(4))
  end

  it 'raises RangeError for beginingless range with excluded end and Numeric non-Integer self.end' do
    range = described_class.new(nil, RangeSpecs::Number.new(4), true)

    expect {
      range.max
    }.to raise_error(TypeError, 'cannot exclude non Integer end value')
  end

  it 'returns self.end for beginingless range and Integer self.end' do
    range = described_class.new(nil, 4)
    expect(range.max).to eq(4)
  end

  # https://bugs.ruby-lang.org/issues/21175
  it 'raises RangeError for beginingless range with excluded end and Integer self.end' do
    range = described_class.new(nil, 4, true)

    expect {
      range.max
    }.to raise_error(TypeError, 'cannot exclude end value with non Integer begin value')
  end

  it 'ignores the right boundary if excluded end' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    expect(range.max).to eq(RangeSpecs::WithSucc.new(3))
  end

  it 'raises TypeError if Numeric range with non-Integer self.end and excluded end' do
    range = described_class.new(RangeSpecs::Number.new(1), RangeSpecs::Number.new(4), true)

    expect {
      range.max
    }.to raise_error(TypeError, 'cannot exclude non Integer end value')
  end

  it 'returns self.end if Integer range and excluded end' do
    range = described_class.new(1, 4, true)
    expect(range.max).to eq(3)
  end

  it 'raises TypeError if Numeric range with non-Integer self.begin, Integer self.end and excluded end' do
    range = described_class.new(1.0, 4, true)

    expect {
      range.max
    }.to raise_error(TypeError, 'cannot exclude end value with non Integer begin value')
  end

  context 'given an argument' do
    it 'returns an array containing n rightmost elements' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))

      expect(range.max(2)).to contain_exactly(
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      )
    end

    it 'allows an argument n be greater than elements number' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))

      expect(range.max(10)).to contain_exactly(
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      )
    end

    it 'ignores the right boundary if excluded end' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)

      expect(range.max(2)).to contain_exactly(
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3)
      )
    end

    it 'raises an ArgumentError when n is negative' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
      expect { range.max(-1) }.to raise_error(ArgumentError, 'negative size (-1)')
    end

    it 'raises a RangeError when passed a Bignum' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))

      expect {
        range.max(bignum_value)
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    it 'returns [] for empty range' do
      range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0), true)
      expect(range.max(2)).to eq([])
    end

    it 'returns [] for backward range' do
      range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
      expect(range.max(2)).to eq([])
    end

    it 'raises RangeError if beginingless range' do
      range = described_class.new(nil, RangeSpecs::WithSucc.new(4))

      expect {
        range.max(2)
      }.to raise_error(RangeError, 'cannot get the maximum of beginless range with custom comparison method')
    end

    it 'raises RangeError for beginingless range with excluded end' do
      range = described_class.new(nil, RangeSpecs::WithSucc.new(4), true)

      expect {
        range.max(2)
      }.to raise_error(RangeError, 'cannot get the maximum of beginless range with custom comparison method')
    end

    # https://bugs.ruby-lang.org/issues/21174
    it 'raises RangeError for beginingless range with excluded end and Integer self.end' do
      range = described_class.new(nil, 4, true)

      expect {
        range.max(2)
      }.to raise_error(RangeError, 'cannot get the maximum of beginless range with custom comparison method')
    end

    it 'raises RangeError if endless range' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), nil)

      expect {
        range.max(2)
      }.to raise_error(RangeError, 'cannot get the maximum of endless range')
    end

    describe 'argument conversion to Integer' do
      it 'converts the passed argument to an Integer using #to_int' do
        range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
        n = double('n', to_int: 2)

        expect(range.max(n)).to contain_exactly(
          RangeSpecs::WithSucc.new(3),
          RangeSpecs::WithSucc.new(4)
        )
      end

      it 'raises a TypeError if the passed argument does not respond to #to_int' do
        range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
        expect { range.max('a') }.to raise_error(TypeError, 'no implicit conversion of String into Integer')
      end

      it 'raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value' do
        range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
        n = double('n', to_int: 'a')

        expect {
          range.max(n)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end

  context 'given a block' do
    it 'compares elements using a block' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
      expect(range.max { |a, b| a <=> b }).to eq(RangeSpecs::WithSucc.new(4))
    end

    it 'returns an array containing the maximum n elements' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))

      expect(range.max(2) { |a, b| a <=> b }).to contain_exactly(
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      )
    end

    it 'returns nil for empty range' do
      range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0), true)
      expect(range.max { |a, b| a <=> b }).to be_nil
    end

    it 'returns nil for backward range' do
      range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
      expect(range.max { |a, b| a <=> b }).to be_nil
    end

    it 'raises RangeError if beginingless range' do
      range = described_class.new(nil, RangeSpecs::WithSucc.new(4))

      expect {
        range.max { |a, b| a <=> b }
      }.to raise_error(RangeError, 'cannot get the maximum of beginless range with custom comparison method')
    end

    it 'raises RangeError for beginingless range with excluded end' do
      range = described_class.new(nil, RangeSpecs::WithSucc.new(4), true)

      expect {
        range.max { |a, b| a <=> b }
      }.to raise_error(RangeError, 'cannot get the maximum of beginless range with custom comparison method')
    end

    it 'raises RangeError if endless range' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), nil)

      expect {
        range.max { |a, b| a <=> b }
      }.to raise_error(RangeError, 'cannot get the maximum of endless range')
    end

    it 'ignores the right boundary if excluded end' do
      range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
      expect(range.max { |a, b| a <=> b }).to eq(RangeSpecs::WithSucc.new(3))
    end
  end
end
