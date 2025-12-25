require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  subject(:refresh_token) { build(:refresh_token) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:token_digest) }
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_uniqueness_of(:token_digest) }
  end

  describe ".digest" do
    it "returns a deterministic sha256 hex digest" do
      raw = "abc123"
      expect(described_class.digest(raw)).to eq(Digest::SHA256.hexdigest(raw))
    end
  end

  describe "#expired?" do
    it "is true when expires_at is in the past" do
      token = build(:refresh_token, expires_at: 1.second.ago)
      expect(token.expired?).to be(true)
    end

    it "is false when expires_at is in the future" do
      token = build(:refresh_token, expires_at: 1.second.from_now)
      expect(token.expired?).to be(false)
    end
  end

  describe "#revoked?" do
    it "is true when revoked_at is present" do
      token = build(:refresh_token, revoked_at: Time.current)
      expect(token.revoked?).to be(true)
    end

    it "is false when revoked_at is nil" do
      token = build(:refresh_token, revoked_at: nil)
      expect(token.revoked?).to be(false)
    end
  end

  describe "#active?" do
    it "is true when not expired and not revoked" do
      token = build(:refresh_token, expires_at: 1.day.from_now, revoked_at: nil)
      expect(token.active?).to be(true)
    end

    it "is false when expired" do
      token = build(:refresh_token, expires_at: 1.second.ago, revoked_at: nil)
      expect(token.active?).to be(false)
    end

    it "is false when revoked" do
      token = build(:refresh_token, expires_at: 1.day.from_now, revoked_at: Time.current)
      expect(token.active?).to be(false)
    end
  end
end
