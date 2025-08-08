# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
  end
end
