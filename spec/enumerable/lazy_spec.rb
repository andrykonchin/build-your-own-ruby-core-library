require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe "Enumerable#lazy" do
  it "returns an instance of Enumerator::Lazy" do
    expect(EnumerableSpecs::Numerous.new.lazy).to be_an_instance_of(Enumerator::Lazy)
  end
end
