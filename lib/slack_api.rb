# Slack API
class SlackAPI
  SLACK_URI = URI(ENV["SLACK_URL"])

  include HTTParty
  base_uri "#{SLACK_URI.scheme}://#{SLACK_URI.hostname}"

  def initialize(unfuddle_api)
    @unfuddle = unfuddle_api
  end

  def post_message(activity)
    return if activity.empty?

    payload = {
      body: Oj.dump("attachments" => build_slack_attachments(activity)),
      headers: { "Content-Type" => "application/json" }
    }

    self.class.post(SLACK_URI.request_uri, payload)
  end

  def build_slack_attachments(events)
    attachments = []

    events.each do |num, ticket_events|
      url = @unfuddle.ticket_url(num)

      att = {
        "fallback" => "#{ticket_events.count} Updates on ##{num} – #{url}",
        "title" => "Ticket ##{num} – #{@unfuddle.ticket(num)['summary']}",
        "title_link" => url,
        "fields" => [],

        "mrkdwn_in" => %w[text title fields pretext]
      }

      ticket_events.each { |ev| handle_event ev, att }

      attachments << att
    end

    attachments
  end

protected

  # TODO: Break out the case logic into separate methods
  def handle_event(ev, att)
    case ev["event"]
    when "create"
      if ev["record_type"] == "Ticket"
        att["title"] = "*NEW* #{att['title']}"
        ticket = ev["record"]["ticket"]
        if ticket["description"].nil?
          att["fields"] << {
            "title" => "Description",
            "value" => ev["record"]["ticket"]["description"],
            "short" => false
          }
        end

        ev["description"].scan(/\*\*(.+?)\*\*\s+(.+?)\./).each do |(title, value)|
          att["fields"] << {
            "title" => title,
            "value" => value,
            "short" => true
          }
        end
      else
        att["fields"] << {
          "title" => "New Comment",
          "value" => ev["record"]["comment"]["body"].gsub("**", "_"),
          "short" => false
        }
      end
    when "status_update"
      field, from, to = ev["description"].scan(/\*\*(.+?)\*\*.*\*(.+?)\*.*\*(.+?)\*\./).flatten
      att["fields"] << {
        "title" => field,
        "value" => "#{from} ⇒ #{to}",
        "short" => true
      }
    when "update"
      field = ev["description"].scan(/\*\*(.+?)\*\*/).flatten.first
      att["fields"] << {
        "title" => field,
        "value" => "Changed",
        "short" => true
      }
    when "reassign"
      from, to = ev["description"].scan(/\*(.+?)\* to \*(.+?)\*/).flatten
      att["fields"] << {
        "title" => "Reassign",
        "value" => "#{from} ⇒ #{to}",
        "short" => true
      }
    end
  end
end

