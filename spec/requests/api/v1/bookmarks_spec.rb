# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1 Bookmarks", type: :request do
  describe "GET /api/v1/bookmarks" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }

    let!(:user_bookmark) { create(:bookmark, user: user, title: "Mine", url: "https://example.com/mine") }
    let!(:other_bookmark) { create(:bookmark, user: other_user, title: "Other", url: "https://example.com/other") }

    it "returns 401 when missing bearer token" do
      get "/api/v1/bookmarks"

      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")
      expect(json.dig("error", "message")).to match(/Missing bearer token/i)
    end

    it "returns bookmarks for the authenticated user only" do
      access_token = Auth::IssueTokens.call(user: user)[:access_token]

      get "/api/v1/bookmarks", headers: auth_header(access_token)

      expect(response).to have_http_status(:ok)

      # Depending on your controller you might render an array of hashes
      titles = json.map { |b| b["title"] }
      expect(titles).to include("Mine")
      expect(titles).not_to include("Other")
    end

    it "returns 401 for an invalid token" do
      get "/api/v1/bookmarks", headers: auth_header("garbage")

      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end

    it "returns 401 for an expired token" do
      travel_to(Time.current) do
        access_token = Auth::IssueTokens.call(user: user)[:access_token]
        travel(Auth::JsonWebToken::ACCESS_TOKEN_TTL + 1.second)

        get "/api/v1/bookmarks", headers: auth_header(access_token)

        expect(response).to have_http_status(:unauthorized)
        expect(json.dig("error", "code")).to eq("unauthorized")
      end
    end
  end
end
