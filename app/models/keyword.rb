# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: true

  after_commit :enqueue_reprocessing_for_all_users

  # TODO: Melhorar performance usando redis
  def self.approved?(text)
    return false if text.blank?

    keywords = all.pluck(:word).map(&:downcase)
    downcased_text = text.downcase

    matches = keywords.count { |word| downcased_text.include?(word) }
    matches >= 2
  end

  private

  def enqueue_reprocessing_for_all_users
    user_ids = User.joins(posts: :comments).distinct.pluck(:id)

    user_ids.find_each do |user_id|
      ReprocessUserJob.perform_later(user_id: user_id)
    end
  end
end
