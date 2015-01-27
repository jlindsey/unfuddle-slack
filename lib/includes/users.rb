# Lookup Unfuddle users
module Includes::Users
  UNFUDDLE_PERSON_URI = "/api/v1/people/%d.json"

  def person(id)
    @people ||= {}

    if @people[id].nil?
      request = Net::HTTP::Get.new format(UNFUDDLE_PERSON_URI, id)
      request.basic_auth UNFUDDLE_USER, UNFUDDLE_PASS
      @people[id] = Oj.load @unfuddle_http.request(request).body
    end

    @people[id]
  end

  def user_name(id)
    user = person id
    [user["first_name"], user["last_name"]].compact.join(" ")
  end
end

