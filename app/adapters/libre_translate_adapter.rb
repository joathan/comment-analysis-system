# frozen_string_literal: true

class LibreTranslateAdapter
  API_URL = 'http://localhost:5001/translate'

  class << self
    def translate(text, source: 'en', target: 'pt-BR', format: 'text')
      response = HTTParty.post(
        API_URL,
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
