require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#zip" do
  it "combines each element of the receiver with the element of the same index in arrays given as arguments" do
    expect(EnumerableSpecs::Numerous.new(1,2,3).zip([4,5,6],[7,8,9])).to eq([[1,4,7],[2,5,8],[3,6,9]])
    expect(EnumerableSpecs::Numerous.new(1,2,3).zip).to eq([[1],[2],[3]])
  end

  it "passes each element of the result array to a block and return nil if a block is given" do
    expected = [[1,4,7],[2,5,8],[3,6,9]]
    expect(EnumerableSpecs::Numerous.new(1,2,3).zip([4,5,6],[7,8,9]) do |result_component|
      expect(result_component).to eq(expected.shift)
    end).to eq(nil)
    expect(expected.size).to eq(0)
  end

  it "fills resulting array with nils if an argument array is too short" do
    expect(EnumerableSpecs::Numerous.new(1,2,3).zip([4,5,6], [7,8])).to eq([[1,4,7],[2,5,8],[3,6,nil]])
  end

  it "converts arguments to arrays using #to_ary" do
    convertible = EnumerableSpecs::ArrayConvertible.new(4,5,6)
    expect(EnumerableSpecs::Numerous.new(1,2,3).zip(convertible)).to eq([[1,4],[2,5],[3,6]])
    expect(convertible.called).to eq(:to_ary)
  end

  it "converts arguments to enums using #to_enum" do
    convertible = EnumerableSpecs::EnumConvertible.new(4..6)
    expect(EnumerableSpecs::Numerous.new(1,2,3).zip(convertible)).to eq([[1,4],[2,5],[3,6]])
    expect(convertible.called).to eq(:to_enum)
    expect(convertible.sym).to eq(:each)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.zip(multi)).to eq([[[1, 2], [1, 2]], [[3, 4, 5], [3, 4, 5]], [[6, 7, 8, 9], [6, 7, 8, 9]]])
  end

  it "raises TypeError when some argument isn't Array and doesn't respond to #to_ary and #to_enum" do
    expect { EnumerableSpecs::Numerous.new(1,2,3).zip(Object.new) }.to raise_error(TypeError, "wrong argument type Object (must respond to :each)")
    expect { EnumerableSpecs::Numerous.new(1,2,3).zip(1) }.to raise_error(TypeError, "wrong argument type Integer (must respond to :each)")
    expect { EnumerableSpecs::Numerous.new(1,2,3).zip(true) }.to raise_error(TypeError, "wrong argument type TrueClass (must respond to :each)")
  end
end
