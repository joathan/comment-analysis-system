# frozen_string_literal: true

class AnalyzeUserService
  def initialize(comments)
    @comments = comments
  end

  def call
    total_comments = @comments.count
    keywords = Keyword.pluck(:term)
    keyword_hits = Hash.new(0)

    @comments.each do |comment|
      keywords.each do |keyword|
        keyword_hits[keyword] += 1 if comment.body.downcase.include?(keyword.downcase)
      end
    end

    {
      total_comments: total_comments,
      keyword_hits: keyword_hits,
      score: calculate_score(keyword_hits),
    }
  end

  private

  def calculate_score(keyword_hits)
    keyword_hits.values.sum
  end
end
