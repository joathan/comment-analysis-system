# frozen_string_literal: true

module Api
  module V1
    class ProgressController < ApplicationController
      def show
        job_id = params[:job_id]
        status = RedisStore.get("job_status:#{job_id}") || 'unknown'

        render json: {
          job_id: job_id,
          status: status,
        }
      end
    end
  end
end
