# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    external_id { rand(1..1000) }
  end
end
