# frozen_string_literal: true

class TranslationService
  def initialize(adapter: LibreTranslateAdapter)
    @adapter = adapter
    @logger = Rails.logger
  end

  def translate(text, target: 'pt-BR', source: 'en')
    translated = @adapter.translate(text, source: source, target: target)
    translated.presence || text
  rescue StandardError => e
    @logger.error("TranslationService failed: #{e.message}")
    text
  end
end
