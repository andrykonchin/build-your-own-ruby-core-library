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

RSpec.describe 'Range#size' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  context 'Integer range' do
    it 'returns the number of elements if forward range' do
      expect(described_class.new(1, 16).size).to eq(16)
      expect(described_class.new(1, 16, true).size).to eq(15)
    end

    it 'returns 0 if backward range' do
      range = described_class.new(16, 0)
      expect(range.size).to eq(0)
    end

    it 'returns 0 if empty range' do
      range = described_class.new(0, 0, true)
      expect(range.size).to eq(0)
    end

    it 'returns 0 if infinite backward range' do
      range = described_class.new(16, -Float::INFINITY)
      expect(range.size).to eq(0)
    end

    it 'returns Float::INFINITY if infinite forward range' do
      range = described_class.new(0, Float::INFINITY)
      expect(range.size).to eq(Float::INFINITY)
    end

    it 'returns Float::INFINITY if endless range' do
      range = described_class.new(1, nil)
      expect(range.size).to eq(Float::INFINITY)
    end
  end

  it 'returns nil if non-Integer range' do
    expect(described_class.new(:a, :z).size).to be_nil
    expect(described_class.new('a', 'z').size).to be_nil
  end

  it 'returns nil if non-Integer endless range' do
    range = described_class.new('z', nil)
    expect(range.size).to be_nil
  end

  it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
    expect {
      described_class.new(1.0, 16.0).size
    }.to raise_error(TypeError, "can't iterate from Float")

    expect {
      described_class.new(nil, 1).size
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end
end
