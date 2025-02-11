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

RSpec.describe 'Enumerable#to_set' do
  it 'returns a new Set created from self' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.to_set).to eq(Set[1, 2, 3, 4])
  end

  it 'passes down passed blocks' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
    expect(enum.to_set { |x| x * x }).to eq(Set[1, 4, 9, 16])
  end

  it 'instantiates an object of provided as the first argument set class' do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3)
    set = enum.to_set(EnumerableSpecs::SetSubclass)
    expect(set).to be_a(EnumerableSpecs::SetSubclass)
    expect(set.to_a).to contain_exactly(1, 2, 3)
  end

  it "doesn't check whether argument is a class and just call #new on it" do
    enum = EnumerableSpecs::Numerous.new

    expect {
      enum.to_set([])
    }.to raise_error(NoMethodError, "undefined method 'new' for an instance of Array")
  end

  it 'passes extra arguments to #each' do
    enum = EnumerableSpecs::Numerous.new
    set = enum.to_set(EnumerableSpecs::SetSubclassWithParameters, :a, :b, :c)
    expect(set.arguments_passed).to eq(%i[a b c])
  end

  it 'gathers whole arrays as elements when #each yields multiple' do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.to_set).to eq Set[[1, 2], [3, 4, 5], [6, 7, 8, 9]]
  end
end
