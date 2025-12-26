# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1 Authentication", type: :request do
  describe "POST /api/v1/register" do
    it "creates a user and returns tokens" do
      post "/api/v1/register", params: {
        user: {
          email: "miguel@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }

      expect(response).to have_http_status(:created)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
      expect(json["access_expires_in"]).to eq(15.minutes.to_i)
      expect(json["refresh_expires_at"]).to be_present
    end

    it "returns validation_error when payload is invalid" do
      post "/api/v1/register", params: {
        user: {
          email: "bad",
          password: "123",
          password_confirmation: "nope"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json.dig("error", "code")).to eq("validation_error")
      expect(json.dig("error", "details")).to be_present
    end
  end

  describe "POST /api/v1/login" do
    let!(:user) do
      create(
        :user,
        email: "miguel@example.com",
        password: "Password123!",
        password_confirmation: "Password123!"
      )
    end

    it "returns tokens for valid credentials" do
      post "/api/v1/login", params: { auth: { email: "miguel@example.com", password: "Password123!" } }

      expect(response).to have_http_status(:ok)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
    end

    it "returns 401 for invalid credentials" do
      post "/api/v1/login", params: { auth: { email: "miguel@example.com", password: "wrong" } }

      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end
  end

  describe "refresh + logout lifecycle" do
    let!(:user) { create(:user) }

    it "refresh rotates the refresh token; logout revokes it; refresh then fails" do
      login = Auth::IssueTokens.call(user: user)
      old_refresh = login[:refresh_token]

      post "/api/v1/refresh", params: { auth: { refresh_token: old_refresh } }
      expect(response).to have_http_status(:ok)

      new_refresh = json["refresh_token"]
      expect(new_refresh).to be_present
      expect(new_refresh).not_to eq(old_refresh)

      # old refresh token should now be revoked (rotation)
      post "/api/v1/refresh", params: { auth: { refresh_token: old_refresh } }
      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")

      # logout revokes the current refresh token
      post "/api/v1/logout", params: { auth: { refresh_token: new_refresh } }
      expect(response).to have_http_status(:no_content)

      # refresh should fail after logout
      post "/api/v1/refresh", params: { auth: { refresh_token: new_refresh } }
      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "message")).to match(/revoked/i)
    end
  end
end
