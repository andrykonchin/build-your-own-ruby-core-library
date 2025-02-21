require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#initialize' do
  it 'is private' do
    expect(Range.private_instance_methods).to include(:initialize)
  end

  it 'raises FrozenError when called explicitly on a frozen range' do
    range = Range.new(1, 6)

    expect {
      range.send(:initialize, 0, 1)
    }.to raise_error(FrozenError, "can't modify frozen Range: 1..6")
  end

  it 'raises NameError when called explicitly on a not frozen range' do
    range = Range.new(1, 6)
    range = range.dup # unfreeze it

    expect {
      range.send(:initialize, 0, 1)
    }.to raise_error(NameError, "'initialize' called twice")
  end
end
