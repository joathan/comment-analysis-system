# frozen_string_literal: true

module Api
  module V1
    class AnalyzeController < ApplicationController
      before_action :load_user, only: [:show]

      def create
        username = params[:username]

        render json: { error: 'username is required' }, status: :unprocessable_entity and return if username.blank?

        job = ImportUserJob.perform_later(username: username)

        render json: { job_id: job.job_id, status: 'queued' }, status: :accepted
      end

      def show
        cache_service = MetricsCacheService.new

        render json: {
          user: {
            username: @user.username,
            metrics: cache_service.fetch_user_metrics(@user),
          },
          group: {
            metrics: cache_service.fetch_group_metrics,
          },
        }
      end

      private

      def load_user
        @user = User.find_by(username: params[:username])

        unless @user
          render json: { error: 'User not found' }, status: :not_found
          nil
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Error loading user: #{e.message}")
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end
    end
  end
end
