require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#drop" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "requires exactly one argument" do
    expect{ @enum.drop{} }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1)")
    expect{ @enum.drop(1, 2){} }.to raise_error(ArgumentError, "wrong number of arguments (given 2, expected 1)")
  end

  it "raises ArgumentError if n < 0" do
    expect {
      @enum.drop(-1)
    }.to raise_error(ArgumentError, "attempt to drop negative size")
  end

  it "raises a RangeError when passed a Bignum" do
    expect {
      @enum.drop(bignum_value)
    }.to raise_error(RangeError, "bignum too big to convert into 'long'")
  end

  it "returns [] for empty enumerables" do
    expect(EnumerableSpecs::Empty.new.drop(0)).to eq([])
    expect(EnumerableSpecs::Empty.new.drop(2)).to eq([])
  end

  it "returns [] if dropping all" do
    expect(@enum.drop(5)).to eq([])
    expect(EnumerableSpecs::Numerous.new(3, 2, 1, :go).drop(4)).to eq([])
  end

  describe 'argument conversion to Integer' do
    it "tries to convert n to an Integer using #to_int" do
      expect(@enum.drop(2.3)).to eq([1, :go])

      obj = double('to_int')
      expect(obj).to receive(:to_int).and_return(2)
      expect(@enum.drop(obj)).to eq([1, :go])
    end

    it "raises a TypeError when the passed n cannot be coerced to Integer" do
      expect{ @enum.drop("hat") }.to raise_error(TypeError, "no implicit conversion of String into Integer")
      expect{ @enum.drop(nil) }.to raise_error(TypeError, "no implicit conversion from nil to integer")
    end

    it "raises a TypeError if the passed argument is not numeric and #to_int returns non-Integer value" do
      obj = double("n", to_int: "a")
      expect { @enum.drop(obj) }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
    end
  end

  it "gathers whole arrays as elements when #each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.drop(1)).to eq([[3, 4, 5], [6, 7, 8, 9]])
  end
end
