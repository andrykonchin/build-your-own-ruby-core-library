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

RSpec.describe 'Enumerable#zip' do
  it 'combines each element of the receiver with the element of the same index in enumerables given as arguments' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect(enum.zip([4, 5, 6], [7, 8, 9])).to eq([[1, 4, 7], [2, 5, 8], [3, 6, 9]])
  end

  it 'can be called without arguments' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect(enum.zip).to eq([[1], [2], [3]])
  end

  it 'fills resulting array with nils if an argument enumerable is shorter' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect(enum.zip([4, 5], [7])).to eq([[1, 4, 7], [2, 5, nil], [3, nil, nil]])
  end

  it 'ignores extra elements in an argument enumerable if it is longer' do
    enum = EnumerableSpecs::Numerous.new(1, 2)
    expect(enum.zip([4, 5, 6], [7, 8, 9])).to eq([[1, 4, 7], [2, 5, 8]])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.zip(multi)).to eq([[[1, 2], [1, 2]], [[3, 4, 5], [3, 4, 5]], [[6, 7, 8, 9], [6, 7, 8, 9]]])
  end

  context 'given a block' do
    it 'passes each element of the result array to a block' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3)
      a = []
      enum.zip([4, 5, 6], [7, 8, 9]) { |e| a << e }
      expect(a).to eq([[1, 4, 7], [2, 5, 8], [3, 6, 9]])
    end

    it 'returns nil' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3)
      expect(enum.zip([4, 5, 6], [7, 8, 9]) {}).to be_nil
    end
  end

  describe 'argument conversion to enumerable' do
    it 'converts arguments to enumerators using #to_enum' do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3)
      object = double('enumerable', each: nil)
      allow(object).to receive(:to_enum).with(:each).and_return((4..6).to_enum)
      expect(enum.zip(object)).to eq([[1, 4], [2, 5], [3, 6]])
    end

    it "raises TypeError when some argument doesn't respond to #each" do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.zip(Object.new) }.to raise_error(TypeError, 'wrong argument type Object (must respond to :each)')
      expect { enum.zip(1) }.to raise_error(TypeError, 'wrong argument type Integer (must respond to :each)')
      expect { enum.zip(true) }.to raise_error(TypeError, 'wrong argument type TrueClass (must respond to :each)')
    end
  end
end
