# frozen_string_literal: true

class ReprocessAllCommentsService
  def initialize(relation: Comment.where(state: %i[approved rejected]))
    @relation = relation
  end

  def call
    @relation.find_each do |comment|
      next unless comment.may_process?

      comment.process!
      ProcessCommentJob.perform_later(comment.id)
    end
  end
end
