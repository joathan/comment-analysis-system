# frozen_string_literal: true

class ProcessCommentJob < ApplicationJob
  queue_as :processing

  def perform(comment_id)
    comment = Comment.find(comment_id)

    CommentProcessingService.new(comment).call

    MetricsCacheService.new.invalidate_user(comment.post.user)
    MetricsCacheService.new.invalidate_group
  end
end
