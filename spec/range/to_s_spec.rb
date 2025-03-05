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

RSpec.describe 'Range#to_s' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'returns a string representation of self' do
    expect(described_class.new(0, 1).to_s).to eq('0..1')
    expect(described_class.new('A', 'Z').to_s).to eq('A..Z')
  end

  it 'calls #to_s for self.begin and self.end' do
    a = double('begin', to_s: 'begin', '<=>': 1)
    b = double('end', to_s: 'end', '<=>': 1)
    range = described_class.new(a, b)

    expect(range.to_s).to eq('begin..end')
  end

  it 'uses ... if excluded end' do
    range = described_class.new(0, 1, true)
    expect(range.to_s).to eq('0...1')
  end

  it 'uses "" for the left boundary if beginless range' do
    expect(described_class.new(nil, 1).to_s).to eq('..1')
    expect(described_class.new(nil, 1, true).to_s).to eq('...1')
  end

  it 'uses "" for the right boundary if endless range' do
    expect(described_class.new(1, nil).to_s).to eq('1..')
    expect(described_class.new(1, nil, true).to_s).to eq('1...')
  end

  it 'keeps only .. for (nil..nil) ranges' do
    expect(described_class.new(nil, nil).to_s).to eq('..')
  end

  it 'keeps only ... for (nil...nil) ranges' do
    expect(described_class.new(nil, nil, true).to_s).to eq('...')
  end
end
