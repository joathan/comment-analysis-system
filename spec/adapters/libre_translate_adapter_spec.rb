# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibreTranslateAdapter, :vcr do
  describe '.translate' do
    context 'when the request succeeds' do
      it 'returns the translated text' do
        original = 'Hello, how are you?'
        translated = described_class.translate(original, source: 'en', target: 'pt-BR')

        expect(translated).to be_a(String)
        expect(translated.downcase).to match(/olá|tudo bem|como você está/)
      end
    end

    context 'when the adapter receives an error from the API' do
      it 'logs the error and returns nil' do
        allow(HTTParty).to receive(:post).and_raise(StandardError, 'Connection failed')

        expect(Rails.logger).to receive(:error).with(/LibreTranslateAdapter failed: Connection failed/)
        expect(described_class.translate('Anything')).to be_nil
      end
    end

    context 'when the API returns an invalid response' do
      it 'logs the error and returns nil' do
        response = instance_double(HTTParty::Response,
                                   success?: true,
                                   parsed_response: { 'foo' => 'bar' },
                                   body: '{"foo":"bar"}')
        allow(HTTParty).to receive(:post).and_return(response)

        expect(Rails.logger).to receive(:error).with(/LibreTranslateAdapter invalid response/)
        expect(described_class.translate('Hi')).to be_nil
      end
    end
  end
end
