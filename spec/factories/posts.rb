# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    user
    title { Faker::Lorem.sentence }
    body  { Faker::Lorem.paragraph }
  end
end
