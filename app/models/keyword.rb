# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: true

  def self.approved?(text)
    all.any? { |kw| text.include?(kw.word) }
  end
end
