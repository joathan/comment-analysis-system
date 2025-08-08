# frozen_string_literal: true

class StatisticsController < ApplicationController
  def index
    @user_metrics = User.includes(posts: :comments).map do |user|
      {
        user: user,
        metrics: CommentMetricsService.new(user.comments).as_json,
      }
    end

    @group_metrics = GroupMetricsService.calculate
    @keywords = Keyword.order(:term)
  end
end
