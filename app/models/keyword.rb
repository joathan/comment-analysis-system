# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: true
end
