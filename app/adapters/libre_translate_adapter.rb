# frozen_string_literal: true

class LibreTranslateAdapter
  BASE_URL = Rails.configuration.x.translate.base_url

  class << self
    def translate(text, source: 'en', target: 'pt-BR', format: 'text')
      response = HTTParty.post(
        BASE_URL,
        body: { q: text, source: source, target: target, format: format }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      handle_response(response)
    rescue StandardError => e
      Rails.logger.error("LibreTranslateAdapter failed: #{e.message}")
      nil
    end

    private

    def handle_response(response)
      if response.success? && response.parsed_response['translatedText']
        response.parsed_response['translatedText']
      else
        Rails.logger.error("LibreTranslateAdapter invalid response: #{response.body}")
        nil
      end
    end
  end
end
