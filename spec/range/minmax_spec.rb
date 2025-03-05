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

RSpec.describe 'Range#minmax' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns a 2-element array containing the minimum and the maximum elements using #<=> for comparison' do
    range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(10))

    expect(range.minmax).to eq(
      [
        RangeSpecs::WithSucc.new(4),
        RangeSpecs::WithSucc.new(10)
      ]
    )
  end

  it 'ignores the right boundary if excluded end' do
    range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(10), true)

    expect(range.minmax).to eq(
      [
        RangeSpecs::WithSucc.new(4),
        RangeSpecs::WithSucc.new(9)
      ]
    )
  end

  it 'raises RangeError if beginingless range' do
    range = described_class.new(nil, RangeSpecs::WithSucc.new(10))

    expect {
      range.minmax
    }.to raise_error(RangeError, 'cannot get the minimum of beginless range')
  end

  it 'raises RangeError if endless range' do
    range = described_class.new(RangeSpecs::WithSucc.new(4), nil)

    expect {
      range.minmax
    }.to raise_error(RangeError, 'cannot get the maximum of endless range')
  end

  it 'returns [nil, nil] if empty range' do
    range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0), true)
    expect(range.minmax).to eq([nil, nil])
  end

  it 'returns [nil, nil] if range is backward' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(0))
    expect(range.minmax).to eq([nil, nil])
  end

  it 'returns [element, element] if range contain only one element' do
    range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0))
    expect(range.minmax).to eq([RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(0)])
  end

  context 'given a block' do
    it 'compares elements using a block' do
      range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(10))

      expect(range.minmax { |a, b| b <=> a }).to eq(
        [
          RangeSpecs::WithSucc.new(10),
          RangeSpecs::WithSucc.new(4)
        ]
      )
    end

    it 'raises TypeError if beginingless range' do
      range = described_class.new(nil, RangeSpecs::WithSucc.new(10))

      expect {
        range.minmax { |a, b| b <=> a }
      }.to raise_error(TypeError, "can't iterate from NilClass")
    end

    it 'iterates indefinitly if endless range' do
      range = described_class.new(RangeSpecs::WithSucc.new(4), nil)

      count = 0
      expect(range.minmax { |a, b| break :aborted if count > 10; count += 1; b <=> a }).to eq(:aborted)
    end
  end
end
