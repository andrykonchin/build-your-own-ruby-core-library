require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#find" do
  before :each do
    ScratchPad.record []
    @elements = [2, 4, 6, 8, 10]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
    @empty = []
  end

  it "passes each entry in enum to block while block when block is false" do
    visited_elements = []
    @numerous.find do |element|
      visited_elements << element
      false
    end
    expect(visited_elements).to eq(@elements)
  end

  it "returns nil when the block is false and there is no ifnone proc given" do
    expect(@numerous.find {|e| false }).to eq(nil)
  end

  it "returns the first element for which the block is not false" do
    @elements.each do |element|
      expect(@numerous.find {|e| e > element - 1 }).to eq(element)
    end
  end

  it "returns the value of the ifnone proc if the block is false" do
    fail_proc = -> { "cheeseburgers" }
    expect(@numerous.find(fail_proc) {|e| false }).to eq("cheeseburgers")
  end

  it "doesn't call the ifnone proc if an element is found" do
    fail_proc = -> { raise "This shouldn't have been called" }
    expect(@numerous.find(fail_proc) {|e| e == @elements.first }).to eq(2)
  end

  it "calls the ifnone proc only once when the block is false" do
    times = 0
    fail_proc = -> { times += 1; raise if times > 1; "cheeseburgers" }
    expect(@numerous.find(fail_proc) {|e| false }).to eq("cheeseburgers")
  end

  it "calls the ifnone proc when there are no elements" do
    fail_proc = -> { "yay" }
    expect(@empty.find(fail_proc) {|e| true}).to eq("yay")
  end

  it "ignores the ifnone argument when nil" do
    expect(@numerous.find(nil) {|e| false }).to eq(nil)
  end

  it "passes through the values yielded by #each_with_index" do
    [:a, :b].each_with_index.find { |x, i| ScratchPad << [x, i]; nil }
    expect(ScratchPad.recorded).to eq([[:a, 0], [:b, 1]])
  end

  it "returns an enumerator when no block given" do
    expect(@numerous.find).to be_an_instance_of(Enumerator)
  end

  it "passes the ifnone proc to the enumerator" do
    times = 0
    fail_proc = -> { times += 1; raise if times > 1; "cheeseburgers" }
    expect(@numerous.find(fail_proc).each {|e| false }).to eq("cheeseburgers")
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    expect(multi.find {|e| e == [1, 2] }).to eq([1, 2])
  end

  describe "Enumerable with size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::NumerousWithSize.new(1, 2, 3, 4)
        end

        it "size returns nil" do
          expect(@object.find.size).to eq(nil)
        end
      end
    end
  end

  describe "Enumerable with no size" do
    describe "when no block is given" do
      describe "returned Enumerator" do
        before do
          @object = EnumerableSpecs::Numerous.new(1, 2, 3, 4)
        end

        it "size returns nil" do
          expect(@object.find.size).to eq(nil)
        end
      end
    end
  end
end
