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

RSpec.describe 'Enumerable#chain' do
  before do
    ScratchPad.record []
  end

  it 'returns a chain of self and provided enumerables' do
    one = EnumerableSpecs::Numerous.new(1)
    two = EnumerableSpecs::Numerous.new(2, 3)
    three = EnumerableSpecs::Numerous.new(4, 5, 6)

    chain = one.chain(two, three)

    chain.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq [1, 2, 3, 4, 5, 6]
  end

  it 'returns an Enumerator::Chain' do
    expect(EnumerableSpecs::Numerous.new.chain).to be_an_instance_of(Enumerator::Chain)
  end

  it 'can be called without arguments' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    chain = enum.chain
    chain.each { |e| ScratchPad << e }
    expect(ScratchPad.recorded).to eq [1, 2, 3, 4]
  end
end
