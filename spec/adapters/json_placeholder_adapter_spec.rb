# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonPlaceholderAdapter do
  describe '.fetch_user_posts' do
    let(:user_id) { 1 }

    it 'returns real posts from the API' do
      base = "#{Rails.configuration.x.json_api.base_url}/posts"
      stub_request(:get, base)
        .with(query: { userId: user_id })
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: JSON.generate([{ 'id' => 1, 'userId' => user_id, 'title' => 'T', 'body' => 'B' }])
        )
      posts = described_class.fetch_user_posts(user_id)

      expect(posts).to be_an(Array)
      expect(posts.first).to include('title', 'body')
    end

    it 'returns [] and logs an error if the API returns an error' do
      url = "#{Rails.configuration.x.json_api.base_url}/posts"
      stub_request(:get, url)
        .with(query: { userId: user_id })
        .to_return(status: 500, body: 'Internal Server Error')

      expect(Rails.logger).to receive(:error).with(/JSONPlaceholderAdapter GET #{url} FAILED/)

      posts = described_class.fetch_user_posts(user_id)

      expect(posts).to eq([])
    end
  end

  describe '.fetch_post_comments' do
    let(:post_id) { 1 }

    it 'returns real comments from the post' do
      base = "#{Rails.configuration.x.json_api.base_url}/comments"
      stub_request(:get, base)
        .with(query: { postId: post_id })
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: JSON.generate([{ 'id' => 1, 'postId' => post_id, 'name' => 'N', 'email' => 'e@x', 'body' => 'C' }])
        )
      comments = described_class.fetch_post_comments(post_id)

      expect(comments).to be_an(Array)
      expect(comments.first).to include('name', 'email', 'body')
    end

    it 'returns [] and logs an error if the API returns an error' do
      url = "#{Rails.configuration.x.json_api.base_url}/comments"
      stub_request(:get, url)
        .with(query: { postId: post_id })
        .to_return(status: 404, body: 'Not found')

      expect(Rails.logger).to receive(:error).with(/JSONPlaceholderAdapter GET #{url} FAILED/)

      comments = described_class.fetch_post_comments(post_id)

      expect(comments).to eq([])
    end
  end
end
