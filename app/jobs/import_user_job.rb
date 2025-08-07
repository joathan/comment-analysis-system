# frozen_string_literal: true

class ImportUserJob < ApplicationJob
  queue_as :default

  def perform(username:)
    Redis.current.set("job_status:#{job_id}", 'processing')
    ImportUserService.new(username).call
    Redis.current.set("job_status:#{job_id}", 'done')
  rescue StandardError => e
    Rails.logger.error("ImportUserJob failed: #{e.message}")
    Redis.current.set("job_status:#{job_id}", 'failed')
    raise
  end
end
