# frozen_string_literal: true

class StatisticsController < ApplicationController
  def index
    cache_service = MetricsCacheService.new

    @user_metrics = User.order(:username).map do |user|
      {
        user: user,
        metrics: cache_service.fetch_user_metrics(user),
      }
    end

    @group_metrics = cache_service.fetch_group_metrics
    @keywords = Keyword.order(:term)
  end
end
