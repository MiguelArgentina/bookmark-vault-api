# frozen_string_literal: true

module Auth
  class RotateRefreshToken
    REFRESH_TOKEN_TTL = 30.days
    RAW_REFRESH_BYTES = 48

    class InvalidToken < StandardError; end

    class << self
      def call(raw_refresh_token:)
        old_token_record = find_active_refresh_token!(raw_refresh_token)

        new_raw = SecureRandom.urlsafe_base64(RAW_REFRESH_BYTES)
        new_token_record = RefreshToken.create!(
          user: old_token_record.user,
          token_digest: RefreshToken.digest(new_raw),
          expires_at: Time.current + REFRESH_TOKEN_TTL
        )

        old_token_record.update!(revoked_at: Time.current, replaced_by_id: new_token_record.id)

        {
          user: old_token_record.user,
          access_token: JsonWebToken.encode_access_token(user_id: old_token_record.user.id),
          access_expires_in: JsonWebToken::ACCESS_TOKEN_TTL.to_i,
          refresh_token: new_raw,
          refresh_expires_at: new_token_record.expires_at
        }
      end

      private

      def find_active_refresh_token!(raw)
        digest = RefreshToken.digest(raw.to_s)
        token = RefreshToken.find_by(token_digest: digest)
        raise InvalidToken, "Invalid refresh token" if token.nil?
        raise InvalidToken, "Refresh token revoked" if token.revoked?
        raise InvalidToken, "Refresh token expired" if token.expired?

        token
      end
    end
  end
end
