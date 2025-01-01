require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#each_cons" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(4,3,2,1)
    @in_threes = [[4,3,2],[3,2,1]]
  end

  it "passes element groups to the block" do
    acc = []
    @enum.each_cons(3){|g| acc << g}
    expect(acc).to eq(@in_threes)
  end

  it "raises an ArgumentError if there is not a single parameter > 0" do
    expect{ @enum.each_cons(0){}    }.to raise_error(ArgumentError)
    expect{ @enum.each_cons(-2){}   }.to raise_error(ArgumentError)
    expect{ @enum.each_cons{}       }.to raise_error(ArgumentError)
    expect{ @enum.each_cons(2,2){}  }.to raise_error(ArgumentError)
    expect{ @enum.each_cons(0)      }.to raise_error(ArgumentError)
    expect{ @enum.each_cons(-2)     }.to raise_error(ArgumentError)
    expect{ @enum.each_cons         }.to raise_error(ArgumentError)
    expect{ @enum.each_cons(2,2)    }.to raise_error(ArgumentError)
  end

  it "tries to convert n to an Integer using #to_int" do
    acc = []
    @enum.each_cons(3.3){|g| acc << g}
    expect(acc).to eq(@in_threes)

    obj = double('to_int')
    expect(obj).to receive(:to_int).and_return(3)
    expect(@enum.each_cons(obj){|g| break g.length}).to eq(3)
  end

  it "works when n is >= full length" do
    full = @enum.to_a
    acc = []
    @enum.each_cons(full.length){|g| acc << g}
    expect(acc).to eq([full])
    acc = []
    @enum.each_cons(full.length+1){|g| acc << g}
    expect(acc).to eq([])
  end

  it "yields only as much as needed" do
    cnt = EnumerableSpecs::EachCounter.new(1, 2, :stop, "I said stop!", :got_it)
    expect(cnt.each_cons(2) {|g| break 42 if g[-1] == :stop }).to eq(42)
    expect(cnt.times_yielded).to eq(3)
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.each_cons(2).to_a).to eq([[[1, 2], [3, 4, 5]], [[3, 4, 5], [6, 7, 8, 9]]])
  end

  it "returns self when a block is given" do
    expect(@enum.each_cons(3){}).to eq(@enum)
  end

  describe "when no block is given" do
    it "returns an enumerator" do
      e = @enum.each_cons(3)
      expect(e).to be_an_instance_of(Enumerator)
      expect(e.to_a).to eq(@in_threes)
    end

    describe "Enumerable with size" do
      describe "returned Enumerator" do
        describe "size" do
          it "returns enum size - each_cons argument + 1" do
            enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
            expect(enum.each_cons(10).size).to eq(1)
            expect(enum.each_cons(9).size).to eq(2)
            expect(enum.each_cons(3).size).to eq(8)
            expect(enum.each_cons(2).size).to eq(9)
            expect(enum.each_cons(1).size).to eq(10)
          end

          it "returns 0 when the argument is larger than self" do
            enum = EnumerableSpecs::NumerousWithSize.new(1, 2, 3)
            expect(enum.each_cons(20).size).to eq(0)
          end

          it "returns 0 when the enum is empty" do
            enum = EnumerableSpecs::EmptyWithSize.new
            expect(enum.each_cons(10).size).to eq(0)
          end
        end
      end
    end

    describe "Enumerable with no size" do
      describe "when no block is given" do
        describe "returned Enumerator" do
          it "size returns nil" do
            expect(EnumerableSpecs::Numerous.new(1, 2, 3, 4).each_cons(8).size).to eq(nil)
          end
        end
      end
    end
  end
end
