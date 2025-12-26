require "rails_helper"

RSpec.describe "API V1", type: :request do
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
      json = JSON.parse(response.body)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
    end

    it "returns validation errors for bad payload" do
      post "/api/v1/register", params: { user: { email: "bad", password: "123", password_confirmation: "nope" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json.dig("error", "code")).to eq("validation_error")
      expect(json.dig("error", "details")).to be_present
    end
  end

  describe "POST /api/v1/login" do
    let!(:user) { create(:user, email: "miguel@example.com", password: "Password123!", password_confirmation: "Password123!") }

    it "returns tokens for valid credentials" do
      post "/api/v1/login", params: { auth: { email: "miguel@example.com", password: "Password123!" } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
    end

    it "returns 401 for invalid credentials" do
      post "/api/v1/login", params: { auth: { email: "miguel@example.com", password: "wrong" } }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end
  end

  describe "POST /api/v1/refresh" do
    let!(:user) { create(:user) }

    it "rotates refresh token and returns new tokens" do
      issued = Auth::IssueTokens.call(user: user)
      old_refresh = issued[:refresh_token]

      post "/api/v1/refresh", params: { auth: { refresh_token: old_refresh } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
      expect(json["refresh_token"]).not_to eq(old_refresh)
    end

    it "returns 401 for invalid refresh token" do
      post "/api/v1/refresh", params: { auth: { refresh_token: "nope" } }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end
  end

  describe "POST /api/v1/logout" do
    let!(:user) { create(:user) }

    it "returns 204 even if token is valid" do
      issued = Auth::IssueTokens.call(user: user)

      post "/api/v1/logout", params: { auth: { refresh_token: issued[:refresh_token] } }

      expect(response).to have_http_status(:no_content)
    end

    it "returns 204 even if token is garbage (no token existence leak)" do
      post "/api/v1/logout", params: { auth: { refresh_token: "garbage" } }

      expect(response).to have_http_status(:no_content)
    end
  end
end
