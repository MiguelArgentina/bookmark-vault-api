# frozen_string_literal: true

class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def expired?
    Time.current >= expires_at
  end

  def revoked?
    revoked_at.present?
  end

  def active?
    !expired? && !revoked?
  end

  def self.digest(raw)
    Digest::SHA256.hexdigest(raw)
  end
end
