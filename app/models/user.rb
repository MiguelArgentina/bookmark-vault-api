class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  has_secure_password

  before_validation :normalize_email

  validates :email,
            presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  has_many :refresh_tokens, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
