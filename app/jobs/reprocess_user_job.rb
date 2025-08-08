# frozen_string_literal: true

class ReprocessUserJob < ApplicationJob
  queue_as :processing

  def perform(user_id:)
    user = User.find(user_id)
    user.posts.each do |post|
      post.comments.each do |comment|
        ProcessCommentJob.perform_now(comment.id)
      end
    end
  end
end
