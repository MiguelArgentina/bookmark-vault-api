require "rails_helper"

RSpec.describe Bookmark, type: :model do
  subject(:bookmark) { build(:bookmark) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:url) }

    it "accepts valid urls" do
      expect(build(:bookmark, url: "https://example.com")).to be_valid
      expect(build(:bookmark, url: "http://example.com/path?x=1")).to be_valid
    end

    it "rejects invalid urls" do
      expect(build(:bookmark, url: "notaurl")).not_to be_valid
      expect(build(:bookmark, url: "javascript:alert(1)")).not_to be_valid
    end
  end
end
