# Attachment builders
module Includes::Attachments
  UNFUDDLE_TICKET_FMT = "https://#{Includes::Events::UNFUDDLE_URL.hostname}/a#/projects/%d/tickets/by_number/%d"

  def build_comment_attachment(e)
    pre = "New Comment from *#{user_name e['person_id']}* on #{ticket_link e}"
    field = {
      "title" => "Comment",
      "value" => e["record"]["comment"]["body"],
      "short" => true
    }

    build_attachment pre, field
  end

  def build_new_ticket_attachment(e)
    pre = "New Ticket #{ticket_link e}"

    ticket = e["record"]["ticket"]
    summary = {
      "title" => "Summary",
      "value" => ticket["summary"],
      "short" => false
    }

    description = nil
    unless ticket["description"].nil?
      description = {
        "title" => "Description",
        "value" => ticket["description"],
        "short" => true
      }
    end

    meta = []
    e["description"].scan(/\*\*(.+?)\*\*\s+(.+?)\./).each do |(title, value)|
      meta << {
        "title" => title,
        "value" => value,
        "short" => false
      }
    end

    build_attachment pre, summary, description, *meta
  end

  def build_ticket_update_attachment(e)
    pre = "Updated Ticket #{ticket_link e}"

    change = {
      "title" => "Change",
      "value" => e["description"],
      "short" => false
    }

    build_attachment pre, change
  end

protected

  def ticket_num(e)
    e["ticket_number"] or e["record"]["ticket"]["number"]
  end

  def ticket_url(e, ticket_num)
    format UNFUDDLE_TICKET_FMT, e["project_id"], ticket_num
  end

  def ticket_link(e)
    num = ticket_num e
    "<#{ticket_url e, num}|##{num}>"
  end

  def build_attachment(pre, *fields)
    {
      "fallback" => pre,
      "pretext" => pre,
      "color" => "#093E3F",
      "fields" => fields.compact
    }
  end
end

