require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#each_slice" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(7,6,5,4,3,2,1)
    @sliced = [[7,6,5],[4,3,2],[1]]
  end

  it "passes element groups to the block" do
    acc = []
    @enum.each_slice(3){|g| acc << g}
    expect(acc).to eq(@sliced)
  end

  it "raises an ArgumentError if there is not a single parameter > 0" do
    expect{ @enum.each_slice(0){}    }.to raise_error(ArgumentError)
    expect{ @enum.each_slice(-2){}   }.to raise_error(ArgumentError)
    expect{ @enum.each_slice{}       }.to raise_error(ArgumentError)
    expect{ @enum.each_slice(2,2){}  }.to raise_error(ArgumentError)
    expect{ @enum.each_slice(0)      }.to raise_error(ArgumentError)
    expect{ @enum.each_slice(-2)     }.to raise_error(ArgumentError)
    expect{ @enum.each_slice         }.to raise_error(ArgumentError)
    expect{ @enum.each_slice(2,2)    }.to raise_error(ArgumentError)
  end

  it "tries to convert n to an Integer using #to_int" do
    acc = []
    @enum.each_slice(3.3){|g| acc << g}
    expect(acc).to eq(@sliced)

    obj = double('to_int')
    expect(obj).to receive(:to_int).and_return(3)
    expect(@enum.each_slice(obj){|g| break g.length}).to eq(3)
  end

  it "works when n is >= full length" do
    full = @enum.to_a
    acc = []
    @enum.each_slice(full.length){|g| acc << g}
    expect(acc).to eq([full])
    acc = []
    @enum.each_slice(full.length+1){|g| acc << g}
    expect(acc).to eq([full])
  end

  it "yields only as much as needed" do
    cnt = EnumerableSpecs::EachCounter.new(1, 2, :stop, "I said stop!", :got_it)
    expect(cnt.each_slice(2) {|g| break 42 if g[0] == :stop }).to eq(42)
    expect(cnt.times_yielded).to eq(4)
  end

  it "returns an enumerator if no block" do
    e = @enum.each_slice(3)
    expect(e).to be_an_instance_of(Enumerator)
    expect(e.to_a).to eq(@sliced)
  end

  it "returns self when a block is given" do
    expect(@enum.each_slice(3){}).to eq(@enum)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.each_slice(2).to_a).to eq([[[1, 2], [3, 4, 5]], [[6, 7, 8, 9]]])
  end

  describe "when no block is given" do
    it "returns an enumerator" do
      e = @enum.each_slice(3)
      expect(e).to be_an_instance_of(Enumerator)
      expect(e.to_a).to eq(@sliced)
    end

    describe "Enumerable with size" do
      describe "returned Enumerator" do
        describe "size" do
          it "returns the ceil of Enumerable size divided by the argument value" do
            enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
            expect(enum.each_slice(10).size).to eq(1)
            expect(enum.each_slice(9).size).to eq(2)
            expect(enum.each_slice(3).size).to eq(4)
            expect(enum.each_slice(2).size).to eq(5)
            expect(enum.each_slice(1).size).to eq(10)
          end

          it "returns 0 when the Enumerable is empty" do
            enum = EnumerableSpecs::EmptyWithSize.new
            expect(enum.each_slice(10).size).to eq(0)
          end
        end
      end
    end

    describe "Enumerable with no size" do
      before do
        @object = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
      end

      describe "when no block is given" do
        describe "returned Enumerator" do
          it "size returns nil" do
            expect(@object.each_slice(8).size).to eq(nil)
          end
        end
      end
    end
  end
end
