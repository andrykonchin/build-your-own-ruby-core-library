require 'spec_helper'
require_relative 'fixtures/classes'

  it 'returns an array that contains only unique elements' do
RSpec.describe 'Enumerable#uniq' do
    expect([0, 1, 2, 3].to_enum.uniq { |n| n.even? }).to eq([0, 1])
  end

  it "uses eql? semantics" do
    expect([1.0, 1].to_enum.uniq).to eq([1.0, 1])
  end

  it "compares elements first with hash" do
    x = double('0')
    expect(x).to receive(:hash).at_least(1).and_return(0)
    y = double('0')
    expect(y).to receive(:hash).at_least(1).and_return(0)

    expect([x, y].to_enum.uniq).to eq([x, y])
  end

  it "does not compare elements with different hash codes via eql?" do
    x = double('0')
    expect(x).not_to receive(:eql?)
    y = double('1')
    expect(y).not_to receive(:eql?)

    expect(x).to receive(:hash).at_least(1).and_return(0)
    expect(y).to receive(:hash).at_least(1).and_return(1)

    expect([x, y].to_enum.uniq).to eq([x, y])
  end

  it "compares elements with matching hash codes with #eql?" do
    a = Array.new(2) do
      obj = double('0')
      expect(obj).to receive(:hash).at_least(1).and_return(0)

      def obj.eql?(o)
        false
      end

      obj
    end

    expect(a.uniq).to eq(a)

    a = Array.new(2) do
      obj = double('0')
      expect(obj).to receive(:hash).at_least(1).and_return(0)

      def obj.eql?(o)
        true
      end

      obj
    end

    expect(a.to_enum.uniq.size).to eq(1)
  end

  context 'when yielded with multiple arguments' do
    before :each do
      @enum = Object.new.to_enum
      class << @enum
        def each
          yield 0, 'foo'
          yield 1, 'FOO'
          yield 2, 'bar'
        end
      end
    end

    it 'returns all yield arguments as an array' do
      expect(@enum.uniq { |_, label| label.downcase }).to eq([[0, 'foo'], [2, 'bar']])
    end
  end
end
