require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#min_by" do
  it "returns element for which the block returns the minimum value" do
    enum = EnumerableSpecs::Numerous.new(*%w[4 3 2 1])
    expect(enum.min_by {|obj| obj.to_i }).to eq('1')
  end

  it "compares returned by a block values with #<=> method" do
    enum = EnumerableSpecs::Numerous.new(1, 2, 3)
    expect(enum.min_by { |n| EnumerableSpecs::ReverseComparable.new(n) }).to eq(3)
  end

  it "returns an Enumerator if called without a block" do
    enum = EnumerableSpecs::Numerous.new(4, 3, 2, 1)
    expect(enum.min_by).to be_an_instance_of(Enumerator)
    expect(enum.min_by.to_a).to contain_exactly(4, 3, 2, 1)
    expect(enum.min_by.each {|n| n }).to eq(1)
  end

  it "returns nil for an empty Enumerable" do
    expect(EnumerableSpecs::Empty.new.min_by { 1 }).to be_nil
  end

  it "raises a NoMethodError for returned by a block values not responding to #<=>" do
    enum = EnumerableSpecs::Numerous.new
    expect {
      enum.min_by { BasicObject.new }
    }.to raise_error(NoMethodError, "undefined method '<=>' for an instance of BasicObject")
  end

  it "raises an ArgumentError for incomparable for returned by a block values" do
    enum = EnumerableSpecs::Numerous.new
    expect do
      enum.min_by { EnumerableSpecs::Uncomparable.new  }
    end.to raise_error(ArgumentError, "comparison of EnumerableSpecs::Uncomparable with EnumerableSpecs::Uncomparable failed")
  end

  context "when #each yields multiple" do
    it "gathers whole arrays as elements" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.min_by {|obj| obj}).to eq([1, 2])
    end

    it "yields whole arrays as elements" do
      multi = EnumerableSpecs::YieldsMulti.new
      yielded = []
      multi.min_by {|*args| yielded << args; args}
      expect(yielded).to contain_exactly([[1, 2]], [[3, 4, 5]], [[6, 7, 8, 9]])
    end
  end

  context "when called with an argument n" do
    it "returns an array containing n elements for which a block returned the minimum values" do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min_by(2) { |n| n}).to contain_exactly(1, 2)
    end

    it "returns an Enumerator if called without a block" do
      enum = EnumerableSpecs::Numerous.new(4, 3, 2, 1)
      expect(enum.min_by(2)).to be_an_instance_of(Enumerator)
      expect(enum.min_by(2).to_a).to contain_exactly(4, 3, 2, 1)
      expect(enum.min_by(2).each {|n| n }).to contain_exactly(1, 2)
    end

    it "ignores nil value" do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min_by(nil) { |n| n}).to eq(1)
    end

    it "allows an argument n be greater than elements number" do
      enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      expect(enum.min_by(10) { |n| n}).to contain_exactly(1, 2, 3, 4)
    end

    it "raises an ArgumentError when n is negative" do
      enum = EnumerableSpecs::Numerous.new
      expect { enum.min_by(-1) { |n| n} }.to raise_error(ArgumentError, "negative size (-1)")
    end

    it "raises a RangeError when passed a Bignum" do
      enum = EnumerableSpecs::Empty.new
      expect {
        enum.min_by(bignum_value) { |n| n}
      }.to raise_error(RangeError, "bignum too big to convert into 'long'")
    end

    describe 'argument conversion to Integer' do
      it "converts the passed argument to an Integer using #to_int" do
        enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        n = double('n', to_int: 2)
        expect(enum.min_by(n) {|n| n}).to contain_exactly(1, 2)
      end

      it "raises a TypeError if the passed argument does not respond to #to_int" do
        enum = EnumerableSpecs::Numerous.new
        expect {
          enum.min_by("a") {|n| n}
        }.to raise_error(TypeError, "no implicit conversion of String into Integer")
      end

      it "raises a TypeError if the passed argument responds to #to_int but it returns non-Integer value" do
        enum = EnumerableSpecs::Numerous.new
        n = double("n", to_int: "a")

        expect {
          enum.min_by(n) {|n| n}
        }.to raise_error(TypeError, "can't convert RSpec::Mocks::Double to Integer (RSpec::Mocks::Double#to_int gives String)")
      end
    end
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns the enumerable size" do
          enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
          expect(enum.min_by.size).to eq(enum.size)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        it "size returns nil" do
          enum = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
          expect(enum.min_by.size).to eq(nil)
        end
      end
    end
  end
end
