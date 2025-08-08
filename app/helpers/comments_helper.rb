# frozen_string_literal: true

module CommentsHelper
  def highlight_matched_keywords(comment)
    return [] unless comment.state == 'approved'

    keywords = Keyword.pluck(:term)
    keywords.select { |kw| comment.body.to_s.downcase.include?(kw.downcase) }
  end
end
