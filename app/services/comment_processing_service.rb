# frozen_string_literal: true

class CommentProcessingService
  def initialize(comment, translation_service: TranslationService.new, metrics_cache: MetricsCacheService.new,
                 logger: Rails.logger, target_language: 'pt-BR')
    @comment = comment
    @translation_service = translation_service
    @metrics_cache = metrics_cache
    @logger = logger
    @target_language = target_language
  end

  def call
    @comment.with_lock do
      return unless @comment.may_process?

      @comment.process!

      translated
      change_state
      invalidate_cache
    end
  rescue StandardError => e
    @logger.error("CommentProcessingService failed for comment_id=#{@comment.id}: #{e.class} - #{e.message}")
    raise
  end

  private

  def translated
    translated = @translation_service.translate(@comment.body, target: @target_language)
    @comment.update!(translated_body: translated.presence || @comment.body)
  rescue StandardError => e
    @logger.warn("Translation failed: #{e.message}")
    @comment.update!(translated_body: @comment.body)
  end

  def change_state
    if Keyword.approved?(@comment.translated_body)
      @comment.approve!
    else
      @comment.reject!
    end
  end

  def invalidate_cache
    @metrics_cache.invalidate_user(@comment.post.user)
    @metrics_cache.invalidate_group
  end
end
