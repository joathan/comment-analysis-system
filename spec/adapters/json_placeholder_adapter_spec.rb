# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonPlaceholderAdapter, type: :adapter do
  describe '.fetch_user_posts' do
    let(:user_id) { 123 }
    let(:url) { 'http://localhost:3011/posts' }
    let(:response_body) do
      [
        { 'id' => 1, 'title' => 'Post 1', 'body' => 'Body 1' },
        { 'id' => 2, 'title' => 'Post 2', 'body' => 'Body 2' }
      ]
    end

    before do
      stub_request(:get, url)
        .with(query: { userId: user_id })
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns user posts from API' do
      posts = described_class.fetch_user_posts(user_id)

      expect(posts).to eq(response_body)
      expect(WebMock).to have_requested(:get, url).with(query: { userId: user_id })
    end

    it 'returns [] and logs error if API returns error' do
      stub_request(:get, url)
        .with(query: { userId: user_id })
        .to_return(status: 500, body: 'Internal Server Error')

      expect(Rails.logger).to receive(:error).with(/JSONPlaceholderAdapter GET #{url} FAILED/)

      posts = described_class.fetch_user_posts(user_id)

      expect(posts).to eq([])
    end
  end

  describe '.fetch_post_comments' do
    let(:post_id) { 99 }
    let(:url) { 'http://localhost:3011/comments' }
    let(:comments_body) do
      [
        { 'id' => 1, 'name' => 'Comentador', 'email' => 'foo@bar.com', 'body' => 'Ótimo post' }
      ]
    end

    before do
      stub_request(:get, url)
        .with(query: { postId: post_id })
        .to_return(status: 200, body: comments_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns post comments from API' do
      comments = described_class.fetch_post_comments(post_id)

      expect(comments).to eq(comments_body)
      expect(WebMock).to have_requested(:get, url).with(query: { postId: post_id })
    end

    it 'returns [] and logs error if API returns error' do
      stub_request(:get, url)
        .with(query: { postId: post_id })
        .to_return(status: 404, body: 'Not found')

      expect(Rails.logger).to receive(:error).with(/JSONPlaceholderAdapter GET #{url} FAILED/)

      comments = described_class.fetch_post_comments(post_id)

      expect(comments).to eq([])
    end
  end
end
