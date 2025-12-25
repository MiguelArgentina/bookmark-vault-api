class ApplicationController < ActionController::API
  private

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
