# Redis container class
class RedisContainer
  REDIS_CONN_URL = ENV["REDISCLOUD_URL"] || "redis://localhost:6379"
  REDIS_KEY = "unfuddle:seen_keys"

  class << self
    def sismember(id)
      client.sismember REDIS_KEY, id
    end

    def sadd(id)
      client.sadd REDIS_KEY, id
    end

    def client
      if @redis.nil?
        @redis = Redis.new url: REDIS_CONN_URL
        @redis.del REDIS_KEY if ARGV.include? "--debug"
      end

      @redis
    end
  end
end

