# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # c.ignore_localhost = true

  c.default_cassette_options = {
    record: :once,
    re_record_interval: 30 * 24 * 60 * 60
  }

  c.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
end
