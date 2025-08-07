# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :term, presence: true, uniqueness: true

  after_commit :enqueue_reprocessing_for_all_users

  # TODO: Melhorar performance usando redis
  def self.approved?(text)
    return false if text.blank?

    keywords = all.pluck(:term).map(&:downcase)
    downcased_text = text.downcase

    matches = keywords.count { |term| downcased_text.include?(term) }
    matches >= 2
  end

  private

  def enqueue_reprocessing_for_all_users
    User.joins(posts: :comments)
        .distinct
        .select(:id)
        .find_each(batch_size: 1000) do |user|
      ReprocessUserJob.perform_later(user_id: user.id)
    end
  end
end
