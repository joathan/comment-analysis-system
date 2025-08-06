# frozen_string_literal: true

class Comment < ApplicationRecord
  include AASM

  belongs_to :post

  aasm column: :state do
    state :new, initial: true
    state :processing
    state :approved
    state :rejected

    event :process do
      transitions from: :new, to: :processing
    end

    event :approve do
      transitions from: :processing, to: :approved
    end

    event :reject do
      transitions from: :processing, to: :rejected
    end
  end
end
