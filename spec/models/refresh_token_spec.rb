require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  subject(:token) { build(:refresh_token) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:token_digest) }
    it { is_expected.to validate_presence_of(:expires_at) }
  end

  describe "basic state behavior" do
    it "can be revoked" do
      t = create(:refresh_token, revoked_at: nil)
      t.update!(revoked_at: Time.current)
      expect(t.revoked_at).to be_present
    end

    it "can be expired" do
      t = build(:refresh_token, expires_at: 1.minute.ago)
      expect(t.expires_at).to be < Time.current
    end
  end
end
