require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#count" do
  before :each do
    @elements = [1, 2, 4, 2]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  describe "when no argument or a block" do
    it "returns size" do
      expect(@numerous.count).to eq(4)
    end

    describe "with a custom size method" do
      before :each do
        class << @numerous
          def size
            :any_object
          end
        end
      end

      it "ignores the custom size method" do
        expect(@numerous.count).to eq(4)
      end
    end
  end

  it "counts nils if given nil as an argument" do
    expect(EnumerableSpecs::Numerous.new(nil, nil, nil, false).count(nil)).to eq(3)
  end

  it "accepts an argument for comparison using ==" do
    expect(@numerous.count(2)).to eq(2)
  end

  it "uses a block for comparison" do
    expect(@numerous.count{|x| x%2==0 }).to eq(3)
  end

  it "ignores the block when given an argument" do
    expect {
      expect(@numerous.count(4){|x| x%2==0 }).to eq(1)
    }.to complain(/given block not used/)
  end

  describe "when each yields multiple values" do
    it "gathers initial args as elements" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.count {|e| e == 1 }).to eq(1)
    end

    it "accepts an argument for comparison using ==" do
      multi = EnumerableSpecs::YieldsMulti.new
      expect(multi.count([1, 2])).to eq(1)
    end
  end
end
