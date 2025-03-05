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

RSpec.describe 'Range#to_a' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns an array containing elements of self' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4))
    expect(range.to_a).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3),
        RangeSpecs::WithSucc.new(4)
      ]
    )
  end

  it "doesn't yield the last element if excluded end" do
    range = described_class.new(RangeSpecs::WithSucc.new(1), RangeSpecs::WithSucc.new(4), true)
    expect(range.to_a).to eq(
      [
        RangeSpecs::WithSucc.new(1),
        RangeSpecs::WithSucc.new(2),
        RangeSpecs::WithSucc.new(3)
      ]
    )
  end

  it 'returns an empty array if backward range' do
    range = described_class.new(RangeSpecs::WithSucc.new(4), RangeSpecs::WithSucc.new(1))
    expect(range.to_a).to eq([])
  end

  it 'raises RangeError if endless range' do
    range = described_class.new(RangeSpecs::WithSucc.new(1), nil)

    expect {
      range.to_a
    }.to raise_error(RangeError, 'cannot convert endless range to an array')
  end

  it "raises TypeError if a range is not iterable (that's some element doesn't respond to #succ)" do
    range = described_class.new(RangeSpecs::WithoutSucc.new(1), RangeSpecs::WithoutSucc.new(4))
    expect {
      range.size
    }.to raise_error(TypeError, "can't iterate from RangeSpecs::WithoutSucc")

    range = described_class.new(nil, RangeSpecs::WithoutSucc.new(4))
    expect {
      range.size
    }.to raise_error(TypeError, "can't iterate from NilClass")
  end
end
