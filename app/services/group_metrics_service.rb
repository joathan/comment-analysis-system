# frozen_string_literal: true

class GroupMetricsService
  def self.calculate
    users = User.all
    all_comments = Comment.all
    metrics = CommentMetricsService.new(all_comments)

    total_comments = all_comments.count
    approved_count = all_comments.where(state: :approved).count
    rejected_count = all_comments.where(state: :rejected).count

    {
      total_users: users.count,
      total_comments: total_comments,
      approved_comments: approved_count,
      rejected_comments: rejected_count,
      approval_rate: total_comments.zero? ? 0.0 : approved_count.to_f / total_comments,
      average_comment_length: metrics.average_length,
      median_comment_length: metrics.median_length,
      stddev_comment_length: metrics.stddev_length,
    }
  end
end
