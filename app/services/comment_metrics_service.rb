# frozen_string_literal: true

class CommentMetricsService
  def initialize(comments)
    @comments = comments
  end

  def approved_count
    filter_by_status(:approved).count
  end

  def rejected_count
    filter_by_status(:rejected).count
  end

  def approval_rate
    total = @comments.count
    return 0.0 if total.zero?

    approved_count.to_f / total
  end

  def average_length
    Statistics.mean(lengths)
  end

  def median_length
    Statistics.median(lengths)
  end

  def stddev_length
    Statistics.standard_deviation(lengths)
  end

  private

  def filter_by_status(status)
    if @comments.respond_to?(:where)
      @comments.where(state: status)
    else
      @comments.select { |c| c.state.to_s == status.to_s }
    end
  end

  def lengths
    bodies = if @comments.respond_to?(:pluck)
               @comments.pluck(:body)
             else
               @comments.map(&:body)
             end
    bodies.map { |b| b.to_s.length }
  end
end
