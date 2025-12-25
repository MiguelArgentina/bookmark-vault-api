class AddIndexesToRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :expires_at
    add_index :refresh_tokens, :revoked_at
  end
end
