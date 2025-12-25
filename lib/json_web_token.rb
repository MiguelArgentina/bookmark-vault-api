# frozen_string_literal: true
require 'jwt'
class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s
  ACCESS_TOKEN_TTL = 15.minutes
  REFRESH_TOKEN_TTL = 30.days

  def self.encode(payload:, type:)
    exp = case type
          when :access
            Time.current + ACCESS_TOKEN_TTL
          when :refresh
            Time.current + REFRESH_TOKEN_TTL
          else
            raise ArgumentError, "Invalid token type"
          end
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError => e
    e.to_s
  end
end