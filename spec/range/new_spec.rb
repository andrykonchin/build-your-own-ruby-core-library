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

RSpec.describe 'described_class.new' do
  let(:described_class) { BuildYourOwn::RubyCoreLibrary::Range }

  it 'constructs a range using the given begin and end' do
    range = described_class.new(0, 1)

    expect(range.begin).to eq(0)
    expect(range.end).to eq(1)
  end

  it 'includes the end object when the third parameter is omitted' do
    range = described_class.new(0, 1)
    expect(range.exclude_end?).to be false
  end

  it 'excludes end when the third parameter is a truthy value' do
    expect(described_class.new(0, 1, true).exclude_end?).to be true
    expect(described_class.new(0, 1, Object.new).exclude_end?).to be true
    expect(described_class.new(0, 1, 'a').exclude_end?).to be true
  end

  it 'includes end when the third parameter is a falsy value' do
    expect(described_class.new(0, 1, nil).exclude_end?).to be false
    expect(described_class.new(0, 1, false).exclude_end?).to be false
  end

  it "raises an ArgumentError if begin or end doesn't respond to #<=> and range is finit" do
    expect {
      described_class.new(Object.new, 1)
    }.to raise_error(ArgumentError, 'bad value for range')

    expect {
      described_class.new(0, Object.new)
    }.to raise_error(ArgumentError, 'bad value for range')
  end

  it "raises ArgumentError if begin and end respond to #<=> but aren't comparable and range is finit" do
    a = double('begin', '<=>': nil)
    b = double('end', '<=>': nil)

    expect {
      described_class.new(a, b)
    }.to raise_error(ArgumentError, 'bad value for range')
  end

  it "doesn't raise ArgumentError if begin or end doesn't respond to #<=> and range is infinit" do
    expect(described_class.new(Object.new, nil)).to be_an_instance_of(described_class)
    expect(described_class.new(nil, Object.new)).to be_an_instance_of(described_class)
  end

  describe 'beginless/endless range' do
    it 'allows beginless begin boundary' do
      range = described_class.new(nil, 1)
      expect(range.begin).to be_nil
    end

    it 'allows endless end boundary' do
      range = described_class.new(1, nil)
      expect(range.end).to be_nil
    end
  end

  it 'creates a frozen range if the class is Range.class' do
    expect(described_class.new(1, 2).frozen?).to be true
  end

  it 'does not create a frozen range if the class is not Range.class' do
    expect(Class.new(described_class).new(1, 2).frozen?).to be false
  end
end
