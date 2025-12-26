# frozen_string_literal: true

module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
