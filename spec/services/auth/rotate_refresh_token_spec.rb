require "rails_helper"

RSpec.describe Auth::RotateRefreshToken do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  def create_refresh_token_for(user:, raw:)
    RefreshToken.create!(
      user: user,
      token_digest: RefreshToken.digest(raw),
      expires_at: 30.days.from_now,
      revoked_at: nil
    )
  end

  it "rotates an active refresh token: revokes old, creates new, sets replaced_by_id" do
    old_raw = SecureRandom.urlsafe_base64(48)
    old_record = create_refresh_token_for(user: user, raw: old_raw)
    result = nil
    expect {
      result = described_class.call(raw_refresh_token: old_raw)
    }.to change(RefreshToken, :count).by(1)

    old_record.reload
    expect(old_record.revoked_at).to be_present
    expect(old_record.replaced_by_id).to be_present

    new_record = RefreshToken.find(old_record.replaced_by_id)
    expect(new_record.user_id).to eq(user.id)
    expect(new_record.token_digest).to eq(RefreshToken.digest(result[:refresh_token]))
    expect(new_record.revoked_at).to be_nil
    expect(new_record.active?).to be(true)

    payload = Auth::JsonWebToken.decode(result[:access_token])
    expect(payload[:sub]).to eq(user.id)
  end

  it "rejects an unknown refresh token" do
    expect {
      described_class.call(raw_refresh_token: "does-not-exist")
    }.to raise_error(Auth::RotateRefreshToken::InvalidToken)
  end

  it "rejects an expired refresh token" do
    raw = SecureRandom.urlsafe_base64(48)
    RefreshToken.create!(
      user: user,
      token_digest: RefreshToken.digest(raw),
      expires_at: 1.minute.ago,
      revoked_at: nil
    )

    expect {
      described_class.call(raw_refresh_token: raw)
    }.to raise_error(Auth::RotateRefreshToken::InvalidToken)
  end

  it "rejects a revoked refresh token" do
    raw = SecureRandom.urlsafe_base64(48)
    RefreshToken.create!(
      user: user,
      token_digest: RefreshToken.digest(raw),
      expires_at: 30.days.from_now,
      revoked_at: Time.current
    )

    expect {
      described_class.call(raw_refresh_token: raw)
    }.to raise_error(Auth::RotateRefreshToken::InvalidToken)
  end
end
