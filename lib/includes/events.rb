# Events namespace
module Includes::Events
  UNFUDDLE_URL = URI(ENV["UNFUDDLE_URL"])
  UNFUDDLE_USER = ENV["UNFUDDLE_USER"]
  UNFUDDLE_PASS = ENV["UNFUDDLE_PASS"]

  def init_unfuddle!
    @unfuddle_http = Net::HTTP.new UNFUDDLE_URL.host, UNFUDDLE_URL.port
    @unfuddle_http.use_ssl = true
  end

  def fetch_new_events
    request = Net::HTTP::Get.new UNFUDDLE_URL.request_uri
    request.basic_auth UNFUDDLE_USER, UNFUDDLE_PASS
    response = @unfuddle_http.request request

    parsed = Array(Oj.load response.body).reverse
    pare_events parsed
  end

  def pare_events(parsed)
    parsed.select! do |obj|
      (obj["record_type"] == "Ticket" or
         obj["record_type"] == "Comment") and
        not @redis.sismember Includes::Redis::REDIS_KEY, obj["id"]
    end

    parsed.each { |obj| @redis.sadd Includes::Redis::REDIS_KEY, obj["id"] }

    parsed
  end
end

