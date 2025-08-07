# frozen_string_literal: true

class ProcessCommentJob < ApplicationJob
  queue_as :processing

  def perform(comment_id)
    comment = Comment.find(comment_id)
    comment.with_lock do
      return if comment.processing? || comment.approved? || comment.rejected?

      comment.process!

      translated = TranslationService.new.translate(comment.body, target: 'pt-BR')
      comment.update!(body: translated)

      if Keyword.approved?(translated)
        comment.approve!
      else
        comment.reject!
      end

      MetricsCacheService.new.invalidate_user(comment.post.user)
      MetricsCacheService.new.invalidate_group
    end
  end
end
