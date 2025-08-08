# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :term, presence: true, uniqueness: true

  after_commit :clear_cache_and_reprocess

  def self.approved?(text)
    return false if text.blank?

    keywords = cached_terms
    comment_text = text.downcase

    matching_keywords = keywords.count { |keyword| comment_text.include?(keyword) }
    matching_keywords >= 2
  end

  def self.cached_terms
    Rails.cache.fetch('keywords_all_terms', expires_in: 1.hour) do
      pluck(:term).map(&:downcase)
    end
  end

  private

  def clear_cache_and_reprocess
    Rails.cache.delete('keywords_all_terms')

    ReprocessAllCommentsJob.perform_later
  end
end
