require "rails_helper"

RSpec.describe Auth::RevokeRefreshToken do
  let(:user) { create(:user) }

  def create_refresh_token_for(user:, raw:)
    RefreshToken.create!(
      user: user,
      token_digest: RefreshToken.digest(raw),
      expires_at: 30.days.from_now,
      revoked_at: nil
    )
  end

  it "revokes a token and returns true" do
    raw = SecureRandom.urlsafe_base64(48)
    record = create_refresh_token_for(user: user, raw: raw)

    expect(described_class.call(raw_refresh_token: raw)).to be(true)

    record.reload
    expect(record.revoked_at).to be_present
  end

  it "returns false when token does not exist" do
    expect(described_class.call(raw_refresh_token: "nope")).to be(false)
  end

  it "returns false when token is already revoked" do
    raw = SecureRandom.urlsafe_base64(48)
    record = create_refresh_token_for(user: user, raw: raw)
    record.update!(revoked_at: Time.current)

    expect(described_class.call(raw_refresh_token: raw)).to be(false)
  end
end
