# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    user
    title { Faker::Lorem.sentence }
    body  { Faker::Lorem.paragraph }
    sequence(:external_id) { |n| n }
  end
end
