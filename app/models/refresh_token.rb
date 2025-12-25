class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :replaced_by_id, presence: true, if: :replaced_by_id_present?

  private

  def replaced_by_id_present?
    replaced_by_id.present?
  end
end
