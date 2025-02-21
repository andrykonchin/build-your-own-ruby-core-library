require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Range" do
  it "includes Enumerable" do
    expect(Range.include?(Enumerable)).to eq(true)
  end
end
