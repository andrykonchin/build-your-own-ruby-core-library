require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#initialize" do
  before do
    @range = Range.allocate
  end

  it "is private" do
    expect(Range).to have_private_instance_method("initialize")
  end

  it "initializes correctly the Range object when given 2 arguments" do
    expect { @range.send(:initialize, 0, 1) }.not_to raise_error
  end

  it "initializes correctly the Range object when given 3 arguments" do
    expect { @range.send(:initialize, 0, 1, true) }.not_to raise_error
  end

  it "raises an ArgumentError if passed without or with only one argument" do
    expect { @range.send(:initialize) }.to raise_error(ArgumentError)
    expect { @range.send(:initialize, 1) }.to raise_error(ArgumentError)
  end

  it "raises an ArgumentError if passed with four or more arguments" do
    expect { @range.send(:initialize, 1, 3, 5, 7) }.to raise_error(ArgumentError)
    expect { @range.send(:initialize, 1, 3, 5, 7, 9) }.to raise_error(ArgumentError)
  end

  it "raises a FrozenError if called on an already initialized Range" do
    expect { (0..1).send(:initialize, 1, 3) }.to raise_error(FrozenError)
    expect { (0..1).send(:initialize, 1, 3, true) }.to raise_error(FrozenError)
  end

  it "raises an ArgumentError if arguments don't respond to <=>" do
    o1 = Object.new
    o2 = Object.new

    expect { @range.send(:initialize, o1, o2) }.to raise_error(ArgumentError)
  end
end
