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
    let(:service_instance) { instance_double(ImportUserService) }
    
    before do
      allow(ImportUserService).to receive(:new).with(username: username).and_return(service_instance)
    end

    context 'when the service runs successfully' do
      it 'calls the ImportUserService and updates the status in Redis to done' do
        allow(service_instance).to receive(:call)
        
        expect(RedisStore).to receive(:set).with("job_status:#{subject.job_id}", 'processing').ordered
        expect(RedisStore).to receive(:set).with("job_status:#{subject.job_id}", 'done').ordered

        subject.perform(username: username)
      end
    end

    context 'when the service raises an exception' do
      let(:error_message) { 'External API failure' }

      it 'captures the exception, logs the error, updates the status, and re-raises the exception' do
        allow(service_instance).to receive(:call).and_raise(StandardError, error_message)

        expect(RedisStore).to receive(:set).with("job_status:#{subject.job_id}", 'processing').ordered
        expect(RedisStore).to receive(:set).with("job_status:#{subject.job_id}", 'failed').ordered
        
        expect(Rails.logger).to receive(:error).with("ImportUserJob failed: #{error_message}")

        expect {
          subject.perform(username: username)
        }.to raise_error(StandardError, error_message)
      end
    end
  end
end
