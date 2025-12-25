# frozen_string_literal: true

module Auth
  class RevokeRefreshToken
    def self.call(raw_refresh_token:)
      digest = RefreshToken.digest(raw_refresh_token.to_s)
      token = RefreshToken.find_by(token_digest: digest)
      return false if token.nil? || token.revoked?

      token.update!(revoked_at: Time.current)
      true
    end
  end
end
