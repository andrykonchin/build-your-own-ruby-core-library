require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#drop" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "requires exactly one argument" do
    expect{ @enum.drop{} }.to raise_error(ArgumentError)
    expect{ @enum.drop(1, 2){} }.to raise_error(ArgumentError)
  end

  describe "passed a number n as an argument" do
    it "raises ArgumentError if n < 0" do
      expect{ @enum.drop(-1) }.to raise_error(ArgumentError)
    end

    it "tries to convert n to an Integer using #to_int" do
      expect(@enum.drop(2.3)).to eq([1, :go])

      obj = double('to_int')
      expect(obj).to receive(:to_int).and_return(2)
      expect(@enum.drop(obj)).to eq([1, :go])
    end

    it "returns [] for empty enumerables" do
      expect(EnumerableSpecs::Empty.new.drop(0)).to eq([])
      expect(EnumerableSpecs::Empty.new.drop(2)).to eq([])
    end

    it "returns [] if dropping all" do
      expect(@enum.drop(5)).to eq([])
      expect(EnumerableSpecs::Numerous.new(3, 2, 1, :go).drop(4)).to eq([])
    end

    it "raises a TypeError when the passed n cannot be coerced to Integer" do
      expect{ @enum.drop("hat") }.to raise_error(TypeError)
      expect{ @enum.drop(nil) }.to raise_error(TypeError)
    end
  end
end
