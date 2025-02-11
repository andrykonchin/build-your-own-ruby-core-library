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

RSpec.describe 'Enumerable#sort' do
  it 'sorts by the natural order as defined by <=>' do
    enum = EnumerableSpecs::Numerous.new(3, 1, 4, 6, 2, 5)
    expect(enum.sort).to eq([1, 2, 3, 4, 5, 6])
  end

  it 'sorts in order determined by a block if the block is given' do
    enum = EnumerableSpecs::Numerous.new(3, 1, 4, 6, 2, 5)
    expect(enum.sort { |a, b| b <=> a }).to eq([6, 5, 4, 3, 2, 1])
  end

  it 'raises a NoMethodError if elements do not respond to <=>' do
    enum = EnumerableSpecs::Numerous.new(BasicObject.new, BasicObject.new, BasicObject.new)

    expect {
      enum.sort
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it "raises an error if objects can't be compared, that is <=> returns nil" do
    enum = EnumerableSpecs::Numerous.new(EnumerableSpecs::Uncomparable.new, EnumerableSpecs::Uncomparable.new)

    expect {
      enum.sort
    }.to raise_error(ArgumentError, 'comparison of EnumerableSpecs::Uncomparable with EnumerableSpecs::Uncomparable failed')
  end

  context 'when #each yields multiple' do
    it 'gathers whole arrays as elements' do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.sort { |a, b| a <=> b }).to eq([[1, 2], [3, 4, 5], [6, 7, 8, 9]])
    end

    it 'yields multiple values as array' do
      yielded = Set.new
      multi = EnumerableSpecs::YieldsMulti.new
      multi.sort { |*args| yielded += args; 0 }
      expect(yielded).to contain_exactly([1, 2], [3, 4, 5], [6, 7, 8, 9])
    end
  end
end
