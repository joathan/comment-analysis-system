# frozen_string_literal: true

class ProcessCommentJob < ApplicationJob
  queue_as :processing

  def perform(comment_id, force: false)
    comment = Comment.find(comment_id)

    return if !force && (comment.approved? || comment.rejected? || comment.processing?)

    CommentProcessingService.new(comment).call
  end
end
