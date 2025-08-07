# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationService do
  let(:adapter) { class_double(LibreTranslateAdapter) }
  let(:service) { described_class.new(adapter: adapter) }
  let(:original_text) { 'Hello world' }

  context 'when adapter returns a translation' do
    it 'returns the translated text' do
      allow(adapter).to receive(:translate).and_return('Olá mundo')

      expect(service.translate(original_text)).to eq('Olá mundo')
    end
  end

  context 'when adapter returns nil' do
    it 'returns the original text (fallback)' do
      allow(adapter).to receive(:translate).and_return(nil)

      expect(service.translate(original_text)).to eq(original_text)
    end
  end

  context 'when adapter returns an empty string' do
    it 'returns the original text (fallback)' do
      allow(adapter).to receive(:translate).and_return('')

      expect(service.translate(original_text)).to eq(original_text)
    end
  end

  context 'when adapter raises an exception' do
    before { allow(Rails.logger).to receive(:error) }

    it 'logs the error and returns the original text' do
      allow(adapter).to receive(:translate).and_raise(StandardError, 'connection refused')

      expect(Rails.logger).to receive(:error).with(/TranslationService failed: connection refused/)
      expect(service.translate(original_text)).to eq(original_text)
    end
  end
end
