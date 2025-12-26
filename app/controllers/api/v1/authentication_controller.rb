# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      rescue_from Auth::RotateRefreshToken::InvalidToken, with: :render_invalid_refresh_token

      def register
        user = User.new(register_params)

        if user.save
          render json: Auth::IssueTokens.call(user: user), status: :created
        else
          render_validation_error(user)
        end
      end

      def login
        user = User.find_by(email: normalize_email(login_params[:email]))

        unless user&.authenticate(login_params[:password])
          return render_error(
            code: "unauthorized",
            message: "Invalid email or password",
            status: :unauthorized
          )
        end

        render json: Auth::IssueTokens.call(user: user), status: :ok
      end

      def refresh
        result = Auth::RotateRefreshToken.call(raw_refresh_token: refresh_params[:refresh_token])
        render json: result.except(:user), status: :ok
      end

      def logout
        Auth::RevokeRefreshToken.call(raw_refresh_token: logout_params[:refresh_token])
        head :no_content
      end

      private

      def register_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def login_params
        params.require(:auth).permit(:email, :password)
      end

      def refresh_params
        params.require(:auth).permit(:refresh_token)
      end

      def logout_params
        params.require(:auth).permit(:refresh_token)
      end

      def normalize_email(email)
        email.to_s.strip.downcase
      end

      def render_invalid_refresh_token(exception)
        render_error(code: "unauthorized", message: exception.message, status: :unauthorized)
      end
    end
  end
end
