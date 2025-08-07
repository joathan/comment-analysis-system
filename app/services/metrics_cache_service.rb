# frozen_string_literal: true

class MetricsCacheService
  CACHE_USER_KEY    = 'user_metrics:%<user_id>s'
  CACHE_GROUP_KEY   = 'group_metrics'
  CACHE_EXPIRATION  = 1.hour

  def initialize(cache: Rails.cache)
    @cache = cache
  end

  def fetch_user_metrics(user)
    return {} if user.nil?

    @cache.fetch(format(CACHE_USER_KEY, user_id: user.id), expires_in: CACHE_EXPIRATION) do
      CommentMetricsService.new(user.comments).as_json
    end
  end

  def fetch_group_metrics
    @cache.fetch(CACHE_GROUP_KEY, expires_in: CACHE_EXPIRATION) do
      GroupMetricsService.calculate
    end
  end

  def invalidate_user(user)
    return if user.nil?

    @cache.delete(format(CACHE_USER_KEY, user_id: user.id))
  end

  def invalidate_group
    @cache.delete(CACHE_GROUP_KEY)
  end
end
