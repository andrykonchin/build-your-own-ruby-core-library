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

RSpec.describe 'Range#clone' do
  it 'duplicates a range' do
    range = Range.new(1, 3)
    copy = range.clone

    expect(copy.begin).to eq(1)
    expect(copy.end).to eq(3)
  end

  it 'returns a new object' do
    range = Range.new(1, 3)
    copy = range.clone
    expect(copy).not_to equal(range)
  end

  it 'reuses boundary objects' do
    a = RangeSpecs::Element.new(1)
    b = RangeSpecs::Element.new(3)
    range = Range.new(a, b)
    copy = range.clone

    expect(copy.begin).to equal(a)
    expect(copy.end).to equal(b)
  end

  it 'preserves self.exclude_end?' do
    range = Range.new(1, 3, true)
    copy = range.clone
    expect(copy.exclude_end?).to be true

    range = Range.new(1, 3, false)
    copy = range.clone
    expect(copy.exclude_end?).to be false
  end

  it 'returns a frozen object' do
    range = Range.new(1, 3)
    copy = range.clone
    expect(copy.frozen?).not_to be false
  end
end
