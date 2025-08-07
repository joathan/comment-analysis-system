# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keyword, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:word) }
    it { should validate_uniqueness_of(:word) }
  end

  describe '.approved?' do
    before do
      described_class.create!(word: 'ruby')
      described_class.create!(word: 'rails')
    end

    it 'approves when 2 keywords present' do
      expect(described_class.approved?('Ruby on Rails')).to be true
    end

    it 'rejects when fewer than 2 keywords' do
      expect(described_class.approved?('Hello world')).to be false
    end

    it 'ignores case and punctuation' do
      expect(described_class.approved?('RUBY!')).to be false
    end
  end
end
