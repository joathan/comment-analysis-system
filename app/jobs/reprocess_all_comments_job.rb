# frozen_string_literal: true

class ReprocessAllCommentsJob < ApplicationJob
  queue_as :critical

  def perform
    User.find_each do |user|
      ReprocessUserJob.perform_later(user_id: user.id)
    end
  end
end
