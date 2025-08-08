# frozen_string_literal: true

class ReprocessAllCommentsJob < ApplicationJob
  queue_as :critical

  def perform
    User.find_in_batches(batch_size: 100) do |user_batch|
      user_batch.each do |user|
        ReprocessUserJob.perform_later(user_id: user.id)
      end
    end
  end
end
