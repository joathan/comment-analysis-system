# frozen_string_literal: true

class JsonPlaceholderAdapter
  BASE_URL = 'http://localhost:3011'

  class << self
    def fetch_user_posts(user_id)
      get('/posts', userId: user_id)
    end

    def fetch_post_comments(post_id)
      get('/comments', postId: post_id)
    end

    private

    def get(path, params = {})
      url = "#{BASE_URL}#{path}"
      response = HTTParty.get(url, query: params)
      raise StandardError, "API error: #{response.code}" unless response.success?

      response.parsed_response
    rescue StandardError => e
      Rails.logger.error("JSONPlaceholderAdapter GET #{url} FAILED: #{e.message}")
      []
    end
  end
end
