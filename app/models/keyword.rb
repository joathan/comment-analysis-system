# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :term, presence: true, uniqueness: true

  after_commit :enqueue_reprocessing_for_all_users

  # TODO: Melhorar performance usando redis
  def self.approved?(text)
    return if text.blank?

    keywords = Keyword.pluck(:term)

    matching_keywords = keywords.count { |keyword| text.downcase.include?(keyword.downcase) }
    matching_keywords >= 2
  end

  private

  def enqueue_reprocessing_for_all_users
    ReprocessAllCommentsJob.perform_later
  end
end
