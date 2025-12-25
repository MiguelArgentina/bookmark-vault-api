# frozen_string_literal: true

module Auth
  class IssueTokens
    REFRESH_TOKEN_TTL = 30.days
    RAW_REFRESH_BYTES = 48

    def self.call(user:)
      access_token = JsonWebToken.encode_access_token(user_id: user.id)

      raw_refresh_token = SecureRandom.urlsafe_base64(RAW_REFRESH_BYTES)
      RefreshToken.create!(
        user: user,
        token_digest: RefreshToken.digest(raw_refresh_token),
        expires_at: Time.current + REFRESH_TOKEN_TTL
      )

      {
        access_token: access_token,
        access_expires_in: JsonWebToken::ACCESS_TOKEN_TTL.to_i,
        refresh_token: raw_refresh_token,
        refresh_expires_at: (Time.current + REFRESH_TOKEN_TTL)
      }
    end
  end
end
