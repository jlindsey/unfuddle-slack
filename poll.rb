require "bundler/setup"
Bundler.require
unless ENV["REDISCLOUD_URL"]
  require "pry"
  require "dotenv"
  Dotenv.load
end

$LOAD_PATH.unshift File.expand_path("lib", File.dirname(__FILE__))
require "unfuddle_api"
require "slack_api"

# Post unfuddle ticket events to slack
class UnfuddleSlack
  def initialize
    @unfuddle = UnfuddleAPI.new
    @slack = SlackAPI.new @unfuddle
  end

  def run!
    loop do
      @slack.post_message @unfuddle.activity
      sleep 10
    end
  end
end

UnfuddleSlack.new.run!

