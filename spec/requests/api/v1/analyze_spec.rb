# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Analyze API', type: :request do
  describe 'GET /api/v1/analyze/:username' do
    let(:user) { create(:user, username: 'branden') }

    before do
      create(:post, user: user) do |post|
        create_list(:comment, 3, post: post, state: :approved, body: 'awesome great nice')
        create_list(:comment, 2, post: post, state: :rejected, body: 'boring bad')
      end
    end

    it 'returns user and group metrics' do
      get "/api/v1/analyze/#{user.username}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['user']['username']).to eq('branden')
      expect(json['user']['metrics']).to include('approved_count', 'rejected_count')
      expect(json['group']['metrics']).to include('total_users', 'approved_comments')
    end
  end
end
