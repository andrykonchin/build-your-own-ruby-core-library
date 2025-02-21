require 'spec_helper'
require_relative 'fixtures/classes'

RSpec.describe 'Range#exclude_end?' do
  it 'returns true if a range excludes the self.end value' do
    expect(Range.new(0, 1, true).exclude_end?).to be true
  end

  it 'returns false if a range does not exclude the end value' do
    expect(Range.new(0, 1).exclude_end?).to be false
  end
end
