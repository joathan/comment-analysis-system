# frozen_string_literal: true

keywords = %w[
  ruby
  rails
  redis
  sidekiq
  postgresql
  api
  performance
  scalable
  rspec
  cache
  latency
  solid
  clean
  architecture
  documentation
  testing
  tests
  service
  services
]

keywords.each do |term|
  Keyword.find_or_create_by!(term: term)
end

puts "Seeded #{Keyword.count} keywords."
