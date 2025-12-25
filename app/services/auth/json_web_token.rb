# frozen_string_literal: true

module Auth
  class JsonWebToken
    ACCESS_TOKEN_TTL = 15.minutes
    ALGORITHM = "HS256"

    class DecodeError < StandardError; end

    class << self
      def encode_access_token(user_id:)
        now = Time.current.to_i
        payload = {
          sub: user_id,
          iat: now,
          exp: (Time.current + ACCESS_TOKEN_TTL).to_i
        }

        JWT.encode(payload, secret_key, ALGORITHM)
      end

      def decode(token)
        decoded, = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
        decoded.with_indifferent_access
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        raise DecodeError, e.message
      end

      private

      def secret_key
        Rails.application.secret_key_base
      end
    end
  end
end
