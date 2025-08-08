# frozen_string_literal: true

class ProcessCommentJob < ApplicationJob
  queue_as :processing

  def perform(comment_id)
    comment = Comment.find(comment_id)

    CommentProcessingService.new(comment).call
  end
end
