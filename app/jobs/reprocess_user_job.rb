# frozen_string_literal: true

class ReprocessUserJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    user = User.find(user_id)
    comments = Comment.joins(:post).where(posts: { user_id: user.id })

    result = AnalyzeUserService.new(comments).call

    RedisStore.set("user:#{user.id}:analysis", result.to_json)
  end
end
