# frozen_string_literal: true

class RedisStore
  def self.client
    @client ||= Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'))
  end

  def self.set(key, value)
    client.set(key, value)
  end

  def self.get(key)
    client.get(key)
  end

  def self.del(key)
    client.del(key)
  end
end
