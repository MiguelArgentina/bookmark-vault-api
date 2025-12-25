require "rails_helper"

RSpec.describe Auth::IssueTokens do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  it "returns access + refresh tokens and creates a refresh token record" do
    expect { described_class.call(user: user) }.to change(RefreshToken, :count).by(1)

    result = described_class.call(user: user)

    expect(result).to include(:access_token, :access_expires_in, :refresh_token, :refresh_expires_at)
    expect(result[:access_token]).to be_a(String)
    expect(result[:refresh_token]).to be_a(String)

    record = RefreshToken.order(:created_at).last
    expect(record.user_id).to eq(user.id)
    expect(record.token_digest).to eq(RefreshToken.digest(result[:refresh_token]))
    expect(record.expires_at).to be_present
    expect(record.revoked_at).to be_nil
  end

  it "issues a JWT whose subject matches the user id" do
    result = described_class.call(user: user)
    payload = Auth::JsonWebToken.decode(result[:access_token])

    expect(payload[:sub]).to eq(user.id)
  end

  it "sets refresh expiry roughly REFRESH_TOKEN_TTL from now" do
    travel_to(Time.current) do
      result = described_class.call(user: user)
      record = RefreshToken.order(:created_at).last

      expect(record.expires_at.to_i).to be_within(2).of((Time.current + 30.days).to_i)
      expect(result[:refresh_expires_at].to_i).to be_within(2).of(record.expires_at.to_i)
    end
  end
end
