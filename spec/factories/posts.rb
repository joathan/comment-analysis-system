# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    user
    title { Faker::Lorem.sentence }
    body  { Faker::Lorem.paragraph }
    external_id { rand(1..1000) } 
  end
end
