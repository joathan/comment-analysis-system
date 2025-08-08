# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportUserJob, type: :job do
  let(:username) { Faker::Internet.unique.username }

  describe '.perform_later' do
    it 'enqueues the job on the default queue' do
      expect {
        described_class.perform_later(username: username)
      }.to have_enqueued_job(described_class)
        .with(username: username)
        .on_queue('default')
    end
  end

  describe '#perform' do
    it 'calls ImportUserService with the correct username' do
      service_instance = instance_double(ImportUserService)
      expect(ImportUserService).to receive(:new).with(username: username).and_return(service_instance)
      expect(service_instance).to receive(:call)

      described_class.new.perform(username: username)
    end
  end
end
