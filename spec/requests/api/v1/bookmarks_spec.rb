# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1 Bookmarks", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  def access_token_for(u)
    Auth::IssueTokens.call(user: u)[:access_token]
  end

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end

  def json
    JSON.parse(response.body)
  end

  describe "GET /api/v1/bookmarks" do
    it "returns 401 when missing bearer token" do
      get "/api/v1/bookmarks"

      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end

    it "returns only the authenticated user's bookmarks" do
      create(:bookmark, user: user, title: "Mine", url: "https://example.com/mine")
      create(:bookmark, user: other_user, title: "Other", url: "https://example.com/other")

      token = access_token_for(user)
      get "/api/v1/bookmarks", headers: auth_header(token)

      expect(response).to have_http_status(:ok)
      titles = json.map { |b| b["title"] }
      expect(titles).to include("Mine")
      expect(titles).not_to include("Other")
    end
  end

  describe "GET /api/v1/bookmarks/:id" do
    it "returns 401 when missing bearer token" do
      bookmark = create(:bookmark, user: user)
      get "/api/v1/bookmarks/#{bookmark.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end

    it "returns the bookmark when it belongs to the current user" do
      bookmark = create(:bookmark, user: user, title: "Mine", url: "https://example.com/mine")

      token = access_token_for(user)
      get "/api/v1/bookmarks/#{bookmark.id}", headers: auth_header(token)

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(bookmark.id)
      expect(json["title"]).to eq("Mine")
    end

    it "returns 404 when it belongs to another user" do
      bookmark = create(:bookmark, user: other_user, title: "Other", url: "https://example.com/other")

      token = access_token_for(user)
      get "/api/v1/bookmarks/#{bookmark.id}", headers: auth_header(token)

      expect(response).to have_http_status(:not_found)
      expect(json.dig("error", "code")).to eq("not_found")
    end
  end

  describe "POST /api/v1/bookmarks" do
    it "returns 401 when missing bearer token" do
      post "/api/v1/bookmarks", params: { bookmark: { title: "X", url: "https://example.com" } }

      expect(response).to have_http_status(:unauthorized)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end

    it "creates a bookmark for the current user" do
      token = access_token_for(user)

      expect {
        post "/api/v1/bookmarks",
             headers: auth_header(token),
             params: { bookmark: { title: "Docs", url: "https://example.com/docs", tag: "rails" } }
      }.to change(Bookmark, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["title"]).to eq("Docs")
      expect(Bookmark.order(:created_at).last.user_id).to eq(user.id)
    end

    it "returns 422 for invalid payload" do
      token = access_token_for(user)

      post "/api/v1/bookmarks",
           headers: auth_header(token),
           params: { bookmark: { title: "", url: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json.dig("error", "code")).to eq("validation_error")
    end
  end

  describe "PATCH /api/v1/bookmarks/:id" do
    it "updates a bookmark owned by the current user" do
      bookmark = create(:bookmark, user: user, title: "Old", url: "https://example.com/old")
      token = access_token_for(user)

      patch "/api/v1/bookmarks/#{bookmark.id}",
            headers: auth_header(token),
            params: { bookmark: { title: "New" } }

      expect(response).to have_http_status(:ok)
      expect(json["title"]).to eq("New")
      expect(bookmark.reload.title).to eq("New")
    end

    it "returns 404 when trying to update another user's bookmark" do
      bookmark = create(:bookmark, user: other_user, title: "Other", url: "https://example.com/other")
      token = access_token_for(user)

      patch "/api/v1/bookmarks/#{bookmark.id}",
            headers: auth_header(token),
            params: { bookmark: { title: "Hack" } }

      expect(response).to have_http_status(:not_found)
      expect(json.dig("error", "code")).to eq("not_found")
    end

    it "returns 422 for invalid update" do
      bookmark = create(:bookmark, user: user, title: "Ok", url: "https://example.com/ok")
      token = access_token_for(user)

      patch "/api/v1/bookmarks/#{bookmark.id}",
            headers: auth_header(token),
            params: { bookmark: { url: "notaurl" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json.dig("error", "code")).to eq("validation_error")
    end
  end

  describe "DELETE /api/v1/bookmarks/:id" do
    it "deletes a bookmark owned by the current user" do
      bookmark = create(:bookmark, user: user)
      token = access_token_for(user)

      expect {
        delete "/api/v1/bookmarks/#{bookmark.id}", headers: auth_header(token)
      }.to change(Bookmark, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 when trying to delete another user's bookmark" do
      bookmark = create(:bookmark, user: other_user)
      token = access_token_for(user)

      delete "/api/v1/bookmarks/#{bookmark.id}", headers: auth_header(token)

      expect(response).to have_http_status(:not_found)
      expect(json.dig("error", "code")).to eq("not_found")
      expect(Bookmark.exists?(bookmark.id)).to be(true)
    end
  end
end
