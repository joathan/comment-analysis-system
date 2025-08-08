# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    sequence(:external_id) { |n| n }
  end
end
