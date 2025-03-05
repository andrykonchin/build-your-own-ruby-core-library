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

RSpec.describe 'Range#==' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns true if and only if other is a Range, self.begin and self.end are equal with #== and exclude_end is the same' do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)

    expect(a).to eq b
  end

  it "returns false if other isn't a Range" do
    expect(described_class.new(0, 6)).not_to eq Object.new
  end

  it "returns false if self.begin values aren't equal with #==" do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(1), RangeSpecs::WithEqualValue.new(6), true)

    expect(a).not_to eq b
  end

  it "returns false if self.end values aren't equal with #==" do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(7), true)

    expect(a).not_to eq b
  end

  it "returns false if exclude_end? values aren't the same" do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), false)

    expect(a).not_to eq b
  end

  it 'returns true if other is an instance of a Range subclass' do
    subclass = Class.new(described_class)
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)
    b = subclass.new(RangeSpecs::WithEqualValue.new(0), RangeSpecs::WithEqualValue.new(6), true)

    expect(a).to eq b
  end

  it 'returns true for endless Ranges with equal self.begin' do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, true)
    expect(a).to eq b

    a = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, false)
    b = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, false)
    expect(a).to eq b
  end

  it 'returns false for endless Ranges with not equal self.begin' do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(1), nil, true)
    expect(a).not_to eq b
  end

  it 'returns false for endless Ranges with not equal exclude_end?' do
    a = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, true)
    b = described_class.new(RangeSpecs::WithEqualValue.new(0), nil, false)
    expect(a).not_to eq b
  end

  it 'returns true for beginingless Ranges with equal self.end' do
    a = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), true)
    b = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), true)
    expect(a).to eq b

    a = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), false)
    b = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), false)
    expect(a).to eq b
  end

  it 'returns false for beginingless Ranges with not equal self.end' do
    a = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), true)
    b = described_class.new(nil, RangeSpecs::WithEqualValue.new(1), true)
    expect(a).not_to eq b
  end

  it 'returns false for beginingless Ranges with not equal exclude_end?' do
    a = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), true)
    b = described_class.new(nil, RangeSpecs::WithEqualValue.new(0), false)
    expect(a).not_to eq b
  end
end
