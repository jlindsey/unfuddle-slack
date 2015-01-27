# Redis namespace
module Includes::Redis
  REDIS_CONN_URL = ENV["REDISCLOUD_URL"] || "redis://localhost:6379"
  REDIS_KEY = "unfuddle:seen_keys"

  def init_redis!
    @redis = Redis.new url: REDIS_CONN_URL
    @redis.del REDIS_KEY if ARGV.include? "--debug"
  end
end

