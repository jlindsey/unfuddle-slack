require "bundler/setup"
Bundler.require
unless ENV["REDISCLOUD_URL"]
  require "pry"
  require "dotenv"
  Dotenv.load
end
require "net/http"
require "uri"

$LOAD_PATH.unshift File.expand_path("lib", File.dirname(__FILE__))
require "includes"

# Post unfuddle ticket events to slack
class UnfuddleSlack
  include Includes::Redis
  include Includes::Users
  include Includes::Events
  include Includes::Attachments
  include Includes::Slack

  def initialize
    init_redis!
    init_slack!
    init_unfuddle!
  end

  def run!
    loop do
      events = fetch_new_events
      post_to_slack events

      sleep 10
    end
  end
end

UnfuddleSlack.new.run!

