# frozen_string_literal: true

module Api
  module V1
    class BookmarksController < ApplicationController
      before_action :authenticate!

      def index
        render json: current_user.bookmarks.order(created_at: :desc)
      end
    end
  end
end
