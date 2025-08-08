# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentProcessingService, type: :service do
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }
  let(:comment) { create(:comment, post: post, state: :new, body: 'Original text') }
  let(:translation_service) { instance_double(TranslationService, translate: 'Translated text') }
  let(:metrics_cache) { instance_double(MetricsCacheService, invalidate_user: true, invalidate_group: true) }
  let(:logger) { instance_double(Logger, error: true, warn: true) }

  let(:service) do
    described_class.new(
      comment,
      translation_service: translation_service,
      metrics_cache: metrics_cache,
      logger: logger
    )
  end

  describe '#call' do
    context 'when comment is in a processable state' do
      context 'and the comment is approved' do
        before do
          allow(Keyword).to receive(:approved?).with('Translated text').and_return(true)
        end

        it 'transitions the comment to processing and then to approved' do
          expect { service.call }.to change { comment.reload.state }.from('new').to('approved')
        end

        it 'updates the translated_body' do
          service.call
          expect(comment.reload.translated_body).to eq('Translated text')
        end

        it 'invalidates user and group metrics cache' do
          expect(metrics_cache).to receive(:invalidate_user).with(user).once
          expect(metrics_cache).to receive(:invalidate_group).once
          service.call
        end

        it 'uses a database lock' do
          expect(comment).to receive(:with_lock).and_call_original
          service.call
        end
      end

      context 'and the comment is rejected' do
        before do
          allow(Keyword).to receive(:approved?).with('Translated text').and_return(false)
        end

        it 'transitions the comment to processing and then to rejected' do
          expect { service.call }.to change { comment.reload.state }.from('new').to('rejected')
        end
      end
    end

    context 'when comment is not in a processable state' do
      it 'does nothing if the comment is already processing' do
        comment.update!(state: :processing)
        expect(translation_service).not_to receive(:translate)
        service.call
        expect(comment.reload.state).to eq('processing')
      end
    end

    context 'when translation fails' do
      before do
        allow(translation_service).to receive(:translate).and_raise(StandardError, 'API down')
        allow(Keyword).to receive(:approved?).with('Original text').and_return(false)
      end

      it 'logs a warning and uses the original body for processing' do
        expect(logger).to receive(:warn).with('Translation failed: API down')
        service.call
        expect(comment.reload.translated_body).to eq('Original text')
      end

      it 'still changes the comment state' do
        expect { service.call }.to change { comment.reload.state }.to('rejected')
      end
    end

    context 'when a standard error occurs during the process' do
      let(:error_message) { 'Database connection lost' }

      before do
        allow(comment).to receive(:approve!).and_raise(StandardError, error_message)
        allow(Keyword).to receive(:approved?).and_return(true)
      end

      it 'logs the error and re-raises the exception' do
        expect(logger).to receive(:error).with("CommentProcessingService failed for comment_id=#{comment.id}: StandardError - #{error_message}")
        expect { service.call }.to raise_error(StandardError, error_message)
      end

      it 'reverts the comment to its original state due to transaction rollback' do
        expect { service.call }.to raise_error(StandardError)
        expect(comment.reload.state).to eq('new')
      end
    end
  end
end
