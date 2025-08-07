# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statistics do
  describe '.mean' do
    it 'returns 0.0 for an empty array' do
      expect(described_class.mean([])).to eq(0.0)
    end

    it 'calculates mean for numbers' do
      expect(described_class.mean([1, 2, 3, 4])).to eq(2.5)
      expect(described_class.mean([10, 20, 30])).to eq(20.0)
    end

    it 'ignores nils' do
      expect(described_class.mean([1, nil, 3])).to eq(2.0)
    end
  end

  describe '.median' do
    it 'returns 0.0 for an empty array' do
      expect(described_class.median([])).to eq(0.0)
    end

    it 'returns the middle value for odd count' do
      expect(described_class.median([1, 3, 2])).to eq(2)
    end

    it 'returns the average of middle values for even count' do
      expect(described_class.median([1, 2, 3, 4])).to eq(2.5)
    end

    it 'works with unsorted arrays' do
      expect(described_class.median([4, 1, 3, 2])).to eq(2.5)
    end
  end

  describe '.standard_deviation' do
    it 'returns 0.0 for empty or single-element array' do
      expect(described_class.standard_deviation([])).to eq(0.0)
      expect(described_class.standard_deviation([42])).to eq(0.0)
    end

    it 'calculates sample standard deviation' do
      arr = [2, 4, 4, 4, 5, 5, 7, 9]

      expect(described_class.standard_deviation(arr)).to be_within(0.001).of(2.138)
    end

    it 'ignores nils' do
      expect(described_class.standard_deviation([2, nil, 4])).to be_within(0.01).of(1.414)
    end
  end
end
