# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonPlaceholderAdapter, :vcr do
  describe '.fetch_user_posts' do
    let(:user_id) { 1 }

    it 'returns real posts from the API' do
      posts = described_class.fetch_user_posts(user_id)

      expect(posts).to be_an(Array)
      expect(posts.first).to include('title', 'body')
    end

    it 'returns [] and logs an error if the API returns an error' do
      url = 'http://localhost:3011/posts'
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
      comments = described_class.fetch_post_comments(post_id)

      expect(comments).to be_an(Array)
      expect(comments.first).to include('name', 'email', 'body')
    end

    it 'returns [] and logs an error if the API returns an error' do
      url = 'http://localhost:3011/comments'
      stub_request(:get, url)
        .with(query: { postId: post_id })
        .to_return(status: 404, body: 'Not found')

      expect(Rails.logger).to receive(:error).with(/JSONPlaceholderAdapter GET #{url} FAILED/)

      comments = described_class.fetch_post_comments(post_id)

      expect(comments).to eq([])
    end
  end
end
