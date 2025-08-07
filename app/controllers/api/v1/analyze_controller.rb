# frozen_string_literal: true

module Api
  module V1
    class AnalyzeController < ApplicationController
      def create
        username = params[:username]

        render json: { error: 'username is required' }, status: :unprocessable_entity and return if username.blank?

        job = ImportUserJob.perform_later(username: username)

        render json: { job_id: job.job_id, status: 'queued' }, status: :accepted
      end
    end
  end
end
