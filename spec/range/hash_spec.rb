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

RSpec.describe 'Range#hash' do
  it 'returns an Integer' do
    range = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    expect(range.hash).to be_an_instance_of(Integer)
  end

  it 'returns different values for different ranges' do
    a = Range.new(RangeSpecs::Element.new(0), RangeSpecs::Element.new(6))
    b = Range.new(RangeSpecs::Element.new(-1), RangeSpecs::Element.new(1))
    expect(a.hash).not_to eq(b.hash)
  end

  it 'returns the same values for ranges with the same self.begin, self.end and exclude_end? values' do
    from = RangeSpecs::Element.new(0)
    to = RangeSpecs::Element.new(6)

    a = Range.new(from, to)
    b = Range.new(from, to)

    expect(a.hash).to eq(b.hash)
  end
end
