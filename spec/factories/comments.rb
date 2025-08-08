# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    body { Faker::Lorem.sentence }
    state { :new }
    external_id { rand(1..1000) }
    association :post
  end

  trait :approved do
    state { 'approved' }
  end

  trait :rejected do
    state { 'rejected' }
  end
end
