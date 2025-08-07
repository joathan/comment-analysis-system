# frozen_string_literal: true

class ImportUserJob < ApplicationJob
  queue_as :default

  def perform(username:)
    ImportUserService.new(username).call
  end
end
