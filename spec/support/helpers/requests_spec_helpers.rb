# frozen_string_literal: true

module RequestSpecHelpers
  def json_response
    JSON.parse(response.body)
  end
end
