# frozen_string_literal: true

class CommentProcessingService
  def initialize(comment)
    @comment = comment
  end

  def call
    return unless @comment.may_process?

    @comment.process!

    translated = @comment.translated_body.presence || TranslationService.new.translate(@comment.body, target: 'pt-BR')
    @comment.update!(translated_body: translated)

    if Keyword.approved?(translated)
      @comment.approve!
    else
      @comment.reject!
    end
  end
end
