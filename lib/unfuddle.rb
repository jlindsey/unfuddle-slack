require "uri"

# Unfuddle API
class UnfuddleAPI
  UNFUDDLE_URI = URI(ENV["UNFUDDLE_URL"])
  UNFUDDLE_PROJECT_ID = UNFUDDLE_URI.path.scan(%r{/projects/(\d+)/}).flatten.first

  include HTTParty
  base_uri "#{UNFUDDLE_URI.scheme}://#{UNFUDDLE_URI.hostname}"

  def initialize(redis)
    @redis = redis
    @options = {
      basic_auth: {
        username: ENV["UNFUDDLE_USER"],
        password: ENV["UNFUDDLE_PASS"]
      },
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    }
  end

  def activity
    events = self.class.get(UNFUDDLE_URI.request_uri, @options)
    events.select! do |obj|
      (obj["record_type"] == "Ticket" or
         obj["record_type"] == "Comment") and
        not @redis.sismember Includes::Redis::REDIS_KEY, obj["id"]
    end

    events.each_with_object({}) do |obj, hash|
      @redis.sadd Includes::Redis::REDIS_KEY, obj["id"]

      hash[ticket_num_from_event(obj)] ||= []
      hash[ticket_num_from_event(obj)] << obj
    end
  end

  def ticket(num)
    self.class.get("/api/v1/projects/#{UNFUDDLE_PROJECT_ID}/tickets/by_number/#{num}", @options)
  end

  def ticket_num_from_event(obj)
    obj["ticket_number"] or obj["record"]["ticket"]["number"]
  end
end

