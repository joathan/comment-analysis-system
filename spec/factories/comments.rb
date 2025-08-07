# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    body { 'MyString' }
    state { :new }
    association :post
  end
end
