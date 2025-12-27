require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
    it { is_expected.to have_many(:refresh_tokens).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value("miguel@example.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }
  end

  describe "password" do
    it "hashes the password into password_digest" do
      u = build(:user, password: "Password123!", password_confirmation: "Password123!")
      expect(u.password_digest).to be_present
      expect(u.password_digest).not_to eq("Password123!")
    end

    it "is invalid without a password on create" do
      u = User.new(email: "someone@example.com")
      expect(u).not_to be_valid
      expect(u.errors[:password]).to be_present
    end

    it "is invalid when confirmation doesn't match" do
      u = build(:user, password: "Password123!", password_confirmation: "nope")
      expect(u).not_to be_valid
      expect(u.errors[:password_confirmation]).to be_present
    end
  end
end
