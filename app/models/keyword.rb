# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: true

  def self.approved?(text)
    return false if text.blank?

    keywords = all.pluck(:word).map(&:downcase)
    downcased_text = text.downcase

    matches = keywords.count { |word| downcased_text.include?(word) }
    matches >= 2
  end
end
