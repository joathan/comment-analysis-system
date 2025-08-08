# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    body { Faker::Lorem.sentence }
    state { :new }
    sequence(:external_id) { |n| n }
    association :post
  end

  trait :approved do
    state { 'approved' }
  end

  trait :rejected do
    state { 'rejected' }
  end
end
