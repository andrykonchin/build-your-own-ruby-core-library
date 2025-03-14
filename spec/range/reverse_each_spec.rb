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

RSpec.describe 'Range#reverse_each' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  before do
    ScratchPad.record []
  end

  it 'passes each element of self to the block in reverse order' do # rubocop:disable RSpec/RepeatedExample
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    range.reverse_each { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(4),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(1)
      ]
    )
  end

  it "doesn't yield self.end if end is excluded" do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    range.reverse_each { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(1)
      ]
    )
  end

  it 'returns an Enumerator if no block given' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    e = range.reverse_each

    expect(e).to be_an_instance_of(Enumerator)
    expect(e.to_a).to eq(
      [
        RangeSpecs::WithSucc.new(4),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(1)
      ]
    )
    e.each { |el| ScratchPad << el }
    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(4),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(1)
      ]
    )
  end

  it 'returns self if block given' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.reverse_each {}).to equal(range)
  end

  it 'iterates calling #succ on current element to get the next one' do # rubocop:disable RSpec/RepeatedExample
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    range.reverse_each { |e| ScratchPad << e }

    expect(ScratchPad.recorded).to eq(
      [
        RangeSpecs::WithSucc.new(4),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(1)
      ]
    )
  end

  it 'raises TypeError if endless range' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), nil)

    expect {
      range.reverse_each {}
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  it 'iterates indefinitely if beginingless range with Integer self.end' do
    range = described_class.new(nil, 2)
    range.reverse_each { |e| break if e < 0; ScratchPad << e }
    expect(ScratchPad.recorded).to eq([2, 1, 0])
  end

  it 'raises TypeError if beginingless range with non-Integer self.end' do
    range = described_class.new(nil, RangeSpecs::WithSucc.new(4))

    expect {
      range.reverse_each {}
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
    range = described_class.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))
    expect {
      range.reverse_each {}
    }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")

    range = described_class.new(nil, RangeSpecs::WithSucc.new(4))
    expect {
      range.reverse_each {}
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end

  describe 'finit range' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns the range size when Numeric range' do
          range = described_class.new(1, 4)
          expect(range.reverse_each.size).to eq(range.size)

          range = described_class.new(4, 1)
          expect(range.reverse_each.size).to eq(range.size)

          range = described_class.new(1, Float::INFINITY)
          expect(range.reverse_each.size).to eq(range.size)
        end

        it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
          range = described_class.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))

          expect {
            range.reverse_each.size
          }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")
        end

        it 'size returns the range size when non-Numeric range' do
          range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
          expect(range.reverse_each.size).to eq(range.size)
        end
      end
    end
  end

  describe 'infinit range' do
    describe 'when no block is given' do
      describe 'returned Enumerator' do
        it 'size returns Float::INFINITY if infinit range' do
          enum = described_class.new(1, Float::INFINITY).reverse_each
          expect(enum.size).to eq(Float::INFINITY)
        end

        # https://bugs.ruby-lang.org/issues/21152
        it 'size raises TypeError if endless range' do
          enum = described_class.new(1, nil).reverse_each
          expect {
            enum.size
          }.to raise_error(TypeError, "can't iterate from NilClass")

          enum = described_class.new(RangeSpecs::WithSucc.new(1), nil).reverse_each
          expect {
            enum.size
          }.to raise_error(TypeError, "can't iterate from NilClass")
        end

        it 'size returns Float::INFINITY if beginingless range with Numeric self.end' do
          enum = described_class.new(nil, 1).reverse_each
          expect(enum.size).to eq(Float::INFINITY)
        end

        it 'size raises TypeError if beginingless range with non-Numeric self.end' do
          enum = described_class.new(nil, RangeSpecs::WithSucc.new(4)).reverse_each

          expect {
            enum.size
          }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithSucc")
        end
      end
    end
  end
end
