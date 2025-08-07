# frozen_string_literal: true

class ReprocessAllCommentsJob < ApplicationJob
  queue_as :critical

  def perform
    ReprocessAllCommentsService.new.call
  end
end
