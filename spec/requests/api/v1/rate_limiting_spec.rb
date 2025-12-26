# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API rate limiting", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  def json_if_any
    JSON.parse(response.body)
  rescue JSON::ParserError
    nil
  end

  def env_for_ip(ip)
    { "REMOTE_ADDR" => ip }
  end

  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.cache.store.clear
  end

  describe "POST /api/v1/login (logins/ip: 2 per 20s)" do
    it "throttles after 2 requests from the same ip" do
      ip_env = env_for_ip("1.2.3.4")

      2.times do
        post "/api/v1/login",
             params: { auth: { email: "nope@example.com", password: "wrong" } },
             headers: ip_env

        expect(response).not_to have_http_status(:too_many_requests)
      end

      post "/api/v1/login",
           params: { auth: { email: "nope@example.com", password: "wrong" } },
           headers: ip_env

      expect(response).to have_http_status(:too_many_requests)

      body = json_if_any
      if body
        expect(body.dig("error", "code")).to eq("rate_limited")
      end
    end

    it "resets after the period" do
      ip_env = env_for_ip("1.2.3.4")

      travel_to(Time.current) do
        2.times do
          post "/api/v1/login",
               params: { auth: { email: "nope@example.com", password: "wrong" } },
               headers: ip_env
          expect(response).not_to have_http_status(:too_many_requests)
        end

        post "/api/v1/login",
             params: { auth: { email: "nope@example.com", password: "wrong" } },
             headers: ip_env
        expect(response).to have_http_status(:too_many_requests)

        travel 21.seconds

        post "/api/v1/login",
             params: { auth: { email: "nope@example.com", password: "wrong" } },
             headers: ip_env
        expect(response).not_to have_http_status(:too_many_requests)
      end
    end
  end

  describe "POST /api/v1/register (registrations/ip: 5 per 1m)" do
    it "throttles after 5 requests from the same ip" do
      ip_env = env_for_ip("2.2.2.2")

      5.times do |i|
        post "/api/v1/register",
             params: {
               user: {
                 email: "user#{i}@example.com",
                 password: "Password123!",
                 password_confirmation: "Password123!"
               }
             },
             headers: ip_env

        expect(response).not_to have_http_status(:too_many_requests)
      end

      post "/api/v1/register",
           params: {
             user: {
               email: "user999@example.com",
               password: "Password123!",
               password_confirmation: "Password123!"
             }
           },
           headers: ip_env

      expect(response).to have_http_status(:too_many_requests)

      body = json_if_any
      if body
        expect(body.dig("error", "code")).to eq("rate_limited")
      end
    end
  end

  describe "POST /api/v1/refresh (refresh/ip: 10 per 1m)" do
    it "throttles after 10 requests from the same ip" do
      ip_env = env_for_ip("3.3.3.3")

      10.times do
        post "/api/v1/refresh",
             params: { auth: { refresh_token: "nope" } },
             headers: ip_env

        expect(response).not_to have_http_status(:too_many_requests)
      end

      post "/api/v1/refresh",
           params: { auth: { refresh_token: "nope" } },
           headers: ip_env

      expect(response).to have_http_status(:too_many_requests)

      body = json_if_any
      if body
        expect(body.dig("error", "code")).to eq("rate_limited")
      end
    end
  end

  describe "GET /api/v1/bookmarks (api/authenticated_user: 60 per 1m, per user)" do
    let!(:user) { create(:user) }

    def bearer(token)
      { "Authorization" => "Bearer #{token}" }
    end

    it "throttles after 60 requests for the same user" do
      token = Auth::IssueTokens.call(user: user)[:access_token]

      60.times do
        get "/api/v1/bookmarks", headers: bearer(token)
        expect(response).not_to have_http_status(:too_many_requests)
      end

      get "/api/v1/bookmarks", headers: bearer(token)
      expect(response).to have_http_status(:too_many_requests)

      body = json_if_any
      if body
        expect(body.dig("error", "code")).to eq("rate_limited")
      end
    end
  end
end
