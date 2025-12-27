class ApplicationController < ActionController::API
  private

  def authenticate!
    token = bearer_token
    return render_unauthorized("Missing bearer token") if token.blank?

    payload = ::Auth::JsonWebToken.decode(token)
    user_id = payload[:sub]
    @current_user = User.find_by(id: user_id)

    render_unauthorized("User not found") if @current_user.nil?
  rescue ::Auth::JsonWebToken::DecodeError => e
    render_unauthorized(e.message)
  end

  def current_user
    @current_user
  end

  def bearer_token
    auth_header = request.headers["Authorization"].to_s
    scheme, token = auth_header.split(" ", 2)
    return nil unless scheme&.casecmp("Bearer")&.zero?

    token
  end

  def render_unauthorized(message = "Unauthorized")
    render_error(code: "unauthorized", message: message, status: :unauthorized)
  end

  def render_error(code:, message:, status:, details: nil)
    payload = { error: { code:, message: } }
    payload[:error][:details] = details if details.present?
    render json: payload, status: status
  end

  def render_validation_error(model)
    render_error(
      code: "validation_error",
      message: "Validation failed",
      details: model.errors.to_hash(true),
      status: :unprocessable_entity
    )
  end
end
