# frozen_string_literal: true

module Api
  module V1
    class BookmarksController < ApplicationController
      before_action :authenticate!
      before_action :set_bookmark, only: %i[show update destroy]

      rescue_from ActiveRecord::RecordNotFound do
        render_error(code: "not_found", message: "Resource not found", status: :not_found)
      end

      def index
        render json: current_user.bookmarks.order(created_at: :desc), status: :ok
      end

      def show
        render json: @bookmark, status: :ok
      end

      def create
        bookmark = current_user.bookmarks.new(bookmark_params)

        if bookmark.save
          render json: bookmark, status: :created
        else
          render_validation_error(bookmark)
        end
      end

      def update
        if @bookmark.update(bookmark_params)
          render json: @bookmark, status: :ok
        else
          render_validation_error(@bookmark)
        end
      end

      def destroy
        @bookmark.destroy!
        head :no_content
      end

      private

      def set_bookmark
        @bookmark = current_user.bookmarks.find(params[:id])
      end

      def bookmark_params
        params.require(:bookmark).permit(:title, :url, :tag)
      end
    end
  end
end
