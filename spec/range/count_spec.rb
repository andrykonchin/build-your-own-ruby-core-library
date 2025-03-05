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

RSpec.describe 'Range#count' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns the total count of elements in a range' do
    range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(6))
    expect(range.count).to eq(7)
  end

  it 'ignores the #size method' do
    klass = Class.new(described_class) do
      def size
        0
      end
    end

    range = klass.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(6))
    expect(range.size).to eq(0)
    expect(range.count).to eq(7)
  end

  context 'infinit ranges' do
    it 'returns Float::INFINITY for beginingless ranges' do
      range = described_class.new(nil, RangeSpecs::WithSucc.new(6))
      expect(range.count).to eq(Float::INFINITY)
    end

    it 'returns Float::INFINITY for endless ranges' do
      range = described_class.new(RangeSpecs::WithSucc.new(6), nil)
      expect(range.count).to eq(Float::INFINITY)
    end

    it 'returns Float::INFINITY for nil..nil' do
      range = described_class.new(nil, nil)
      expect(range.count).to eq(Float::INFINITY)
    end
  end

  context 'given an argument' do
    it 'returns the count of elements that equal an argument (that usually is either 0 or 1)' do
      range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(6))
      expect(range.count(RangeSpecs::WithSucc.new(4))).to eq(1)
    end

    it 'compares an argument with elements using #==' do
      range = described_class.new(0, 6)
      object = RangeSpecs::Equals.new(4)
      expect(range.count(object)).to eq(1)
    end

    it 'ignores the block' do
      range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(6))
      object = RangeSpecs::WithSucc.new(4)

      expect {
        expect(range.count(object) { raise }).to eq(1) # rubocop:disable Lint/UnreachableLoop
      }.to complain(/given block not used/)
    end

    context 'infinit ranges' do
      it 'raises TypeError for beginingless ranges' do
        range = described_class.new(nil, RangeSpecs::WithSucc.new(6))
        object = RangeSpecs::WithSucc.new(4)

        expect {
          range.count(object)
        }.to raise_error(TypeError, "can't iterate from NilClass")
      end

      # Don't test endless ranges because #count iterates infinitly

      it 'raises TypeError for nil..nil' do
        range = described_class.new(nil, nil)
        object = RangeSpecs::WithSucc.new(4)

        expect {
          range.count(object)
        }.to raise_error(TypeError, "can't iterate from NilClass")
      end
    end
  end

  context 'given a block' do
    it 'returns the count of elements for which a block returns true' do
      range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(6))
      expect(range.count { |e| e.value.even? }).to eq(4)
    end

    context 'infinit ranges' do
      it 'raises TypeError for beginingless ranges' do
        range = described_class.new(nil, RangeSpecs::WithSucc.new(6))

        expect {
          range.count { |e| e.value.even? }
        }.to raise_error(TypeError, "can't iterate from NilClass")
      end

      it 'iterates infinitly if beginingless range' do
        range = described_class.new(RangeSpecs::WithSucc.new(1), nil)
        expect(range.count { |e| break :aborted if e.value > 10; e.value.even? }).to eq(:aborted)
      end

      it 'raises TypeError for nil..nil' do
        range = described_class.new(nil, nil)

        expect {
          range.count { |e| e.value.even? }
        }.to raise_error(TypeError, "can't iterate from NilClass")
      end
    end
  end
end
