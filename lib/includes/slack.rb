# Post to slack
module Includes::Slack
  SLACK_URL = URI(ENV["SLACK_URL"])

  def init_slack!
    @slack_http = Net::HTTP.new SLACK_URL.host, SLACK_URL.port
    @slack_http.use_ssl = true
    @slack_http.set_debug_output STDOUT if ARGV.include? "--debug"
  end

  def post_to_slack(events)
    payload = { "attachments" => build_slack_attachments(events) }
    return if payload["attachments"].empty?

    request = Net::HTTP::Post.new SLACK_URL.request_uri
    request.body = Oj.dump(payload)
    request["Content-Type"] = "application/json"
    response = @slack_http.request request

    require "pp"
    pp response.body
  end

  def build_slack_attachments(events)
    events.map { |e| dispatched_attachment_build(e) }
  end

protected

  def dispatched_attachment_build(event)
    if event["event"] == "create"
      if event["record_type"] == "Ticket"
        return build_new_ticket_attachment(event)
      else
        return build_comment_attachment(event)
      end
    else
      return build_ticket_update_attachment(event)
    end
  end
end

