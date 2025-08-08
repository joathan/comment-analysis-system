# frozen_string_literal: true

class ReprocessUserJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    user = User.find(user_id)
    user.comments.find_each do |comment|
      ProcessCommentJob.perform_later(comment.id, force: true)
    end
  end
end
