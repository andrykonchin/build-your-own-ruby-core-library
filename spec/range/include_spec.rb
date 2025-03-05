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

RSpec.describe 'Range#include?' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns whether object is an element of self using #== to compare' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.include?(RangeSpecs::WithSucc.new(2))).to be true
    expect(range.include?(RangeSpecs::WithSucc.new(5))).to be false
  end

  it 'ignores self.end if excluded end' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    expect(range.include?(RangeSpecs::WithSucc.new(4))).to be false
  end

  it 'returns false if backward range' do
    range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
    expect(range.include?(RangeSpecs::WithSucc.new(2))).to be false
  end

  it 'returns false if empty range' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(1), true)
    expect(range.include?(RangeSpecs::WithSucc.new(1))).to be false
  end

  it 'raises TypeError for beginingless ranges' do
    expect {
      described_class.new(nil, RangeSpecs::Element.new(10)).include?(Object.new)
    }.to raise_error(TypeError, 'cannot determine inclusion in beginless/endless ranges')
  end

  it 'raises TypeError for endless ranges' do
    expect {
      described_class.new(RangeSpecs::Element.new(0), nil).include?(Object.new)
    }.to raise_error(TypeError, 'cannot determine inclusion in beginless/endless ranges')
  end

  it 'raises TypeError for (nil..nil)' do
    expect {
      described_class.new(nil, nil).include?(Object.new)
    }.to raise_error(TypeError, 'cannot determine inclusion in beginless/endless ranges')
  end

  it "returns false if an argument isn't comparable with range boundaries" do
    range = described_class.new(RangeSpecs::WithSucc.new(0), RangeSpecs::WithSucc.new(6))
    expect(range.include?(Object.new)).to be false
  end

  context 'Numeric ranges' do
    it 'returns true if object is between self.begin and self.end' do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = RangeSpecs::Number.new(5)
      expect(range.include?(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = RangeSpecs::Number.new(-5)
      expect(range.include?(object)).to be false
    end

    it 'returns false if object is greater than self.end' do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = RangeSpecs::Number.new(10)
      expect(range.include?(object)).to be false
    end

    it 'ignores end if excluded end' do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6), true)
      object = RangeSpecs::Number.new(6)
      expect(range.include?(object)).to be false
    end

    it 'returns true if argument is a single element in the range' do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0))
      object = RangeSpecs::Number.new(0)
      expect(range.include?(object)).to be true
    end

    it 'returns false if range is empty' do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(0), true)
      object = RangeSpecs::Number.new(0)
      expect(range.include?(object)).to be false
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      expect(range.include?(Object.new)).to be false
    end

    context 'beginingless range' do
      it 'returns false if object is greater than self.end' do
        range = described_class.new(nil, RangeSpecs::Number.new(6))
        object = RangeSpecs::Number.new(10)
        expect(range.include?(object)).to be false
      end

      it 'returns true if object is smaller than self.end' do
        range = described_class.new(nil, RangeSpecs::Number.new(6))
        object = RangeSpecs::Number.new(0)
        expect(range.include?(object)).to be true
      end
    end

    context 'endless range' do
      it 'returns true if object is greater than self.begin' do
        range = described_class.new(RangeSpecs::Number.new(0), nil)
        object = RangeSpecs::Number.new(10)
        expect(range.include?(object)).to be true
      end

      it 'returns false if object is smaller than self.begin' do
        range = described_class.new(RangeSpecs::Number.new(0), nil)
        object = RangeSpecs::Number.new(-10)
        expect(range.include?(object)).to be false
      end
    end

    it "returns false if object isn't comparable with self.begin and self.end (that's #<=> returns nil)" do
      range = described_class.new(RangeSpecs::Number.new(0), RangeSpecs::Number.new(6))
      object = double('non-comparable', '<=>': nil)
      expect(range.include?(object)).to be false
    end
  end

  context 'Time ranges' do
    # Use 1700000000 as a base timestamp.
    #   Time.at(1700000000) # => 2023-11-15 00:13:20 +0200

    it 'returns true if object is between self.begin and self.end' do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = Time.at(1_700_000_000 + 5)
      expect(range.include?(object)).to be true
    end

    it 'returns false if object is smaller than self.begin' do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = Time.at(1_700_000_000 - 5)
      expect(range.include?(object)).to be false
    end

    it 'returns false if object is greater than self.end' do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = Time.at(1_700_000_000 + 10)
      expect(range.include?(object)).to be false
    end

    it 'ignores end if excluded end' do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6), true)
      object = Time.at(1_700_000_000 + 6)
      expect(range.include?(object)).to be false
    end

    it 'returns true if argument is a single element in the range' do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000))
      object = Time.at(1_700_000_000)
      expect(range.include?(object)).to be true
    end

    it 'returns false if range is empty' do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000), true)
      object = Time.at(1_700_000_000)
      expect(range.include?(object)).to be false
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      expect(range.include?(Object.new)).to be false
    end

    context 'beginingless range' do
      it 'returns false if object is greater than self.end' do
        range = described_class.new(nil, Time.at(1_700_000_000 + 6))
        object = Time.at(1_700_000_000 + 10)
        expect(range.include?(object)).to be false
      end

      it 'returns true if object is smaller than self.end' do
        range = described_class.new(nil, Time.at(1_700_000_000 + 6))
        object = Time.at(1_700_000_000)
        expect(range.include?(object)).to be true
      end
    end

    context 'endless range' do
      it 'returns true if object is greater than self.begin' do
        range = described_class.new(Time.at(1_700_000_000), nil)
        object = Time.at(1_700_000_000 + 10)
        expect(range.include?(object)).to be true
      end

      it 'returns false if object is smaller than self.begin' do
        range = described_class.new(Time.at(1_700_000_000 + 10), nil)
        object = Time.at(1_700_000_000)
        expect(range.include?(object)).to be false
      end
    end

    it "returns false if object isn't comparable with self.begin and self.end (that's #<=> returns nil)" do
      range = described_class.new(Time.at(1_700_000_000), Time.at(1_700_000_000 + 6))
      object = double('non-comparable', '<=>': nil)
      expect(range.include?(object)).to be false
    end
  end

  context 'String ranges' do
    it 'returns whether object is an element of self using #== to compare' do
      range = described_class.new('a', 'ab')

      expect(range.include?('b')).to be true
      expect(range.include?('aa')).to be true
      expect(range.include?('ac')).to be false
    end

    it 'ignores self.end if excluded end' do
      range = described_class.new('a', 'aa', true)
      expect(range.include?('aa')).to be false
    end

    it 'returns false if backward range' do
      range = described_class.new('aa', 'a')
      expect(range.include?('b')).to be false
    end

    it 'returns false if empty range' do
      range = described_class.new('aa', 'aa', true)
      expect(range.include?('aa')).to be false
    end

    it 'raises TypeError for beginingless ranges' do
      expect {
        described_class.new(nil, 'aa').include?(Object.new)
      }.to raise_error(TypeError, 'cannot determine inclusion in beginless/endless ranges')
    end

    it 'raises TypeError for endless ranges' do
      expect {
        described_class.new('aa', nil).include?(Object.new)
      }.to raise_error(TypeError, 'cannot determine inclusion in beginless/endless ranges')
    end

    it "returns false if an argument isn't comparable with range boundaries" do
      range = described_class.new('a', 'aa')
      expect(range.include?(Object.new)).to be false
    end

    it 'returns false if an argument is empty' do
      range = described_class.new('a', 'aa')
      expect(range.include?('')).to be false
    end

    describe 'argument conversion to String' do
      it 'converts the passed argument to a String using #to_str' do
        range = described_class.new('a', 'aa')
        object = double('object', to_str: 'b')
        expect(range.include?(object)).to be true
      end

      it 'returns false if the passed argument does not respond to #to_str' do
        range = described_class.new('a', 'aa')
        expect(range.include?(nil)).to be false
        expect(range.include?([])).to be false
      end

      it 'raises a TypeError if the passed argument responds to #to_str but it returns non-String value' do
        range = described_class.new('a', 'aa')
        object = double('object', to_str: 1)

        expect {
          range.include?(object)
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to String (RSpec::Mocks::Double#to_str gives Integer)")
      end
    end
  end
end
