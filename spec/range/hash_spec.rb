require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range#hash" do
  it "is provided" do
    expect((0..1).respond_to?(:hash)).to eq(true)
    expect(('A'..'Z').respond_to?(:hash)).to eq(true)
    expect((0xfffd..0xffff).respond_to?(:hash)).to eq(true)
    expect((0.5..2.4).respond_to?(:hash)).to eq(true)
  end

  it "generates the same hash values for Ranges with the same start, end and exclude_end? values" do
    expect((0..1).hash).to eq((0..1).hash)
    expect((0...10).hash).to eq((0...10).hash)
    expect((0..10).hash).not_to eq((0...10).hash)
  end

  it "generates an Integer for the hash value" do
    expect((0..0).hash).to be_an_instance_of(Integer)
    expect((0..1).hash).to be_an_instance_of(Integer)
    expect((0...10).hash).to be_an_instance_of(Integer)
    expect((0..10).hash).to be_an_instance_of(Integer)
  end

end
