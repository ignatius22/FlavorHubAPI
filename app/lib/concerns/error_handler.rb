# app/controllers/concerns/error_handler.rb
module ErrorHandler
  extend ActiveSupport::Concern

  def render_unauthorized
    render json: { errors: "User not authenticated" }, status: :unauthorized
  end

  def render_error(errors, status)
    render json: { errors: Array.wrap(errors) }, status: status
  end

  def user_not_authorized
    Rails.logger.warn "Unauthorized attempt by user: #{current_user&.id}"
    render json: { errors: "You are not authorized to perform this action" }, status: :forbidden
  end

  def record_not_found
    render json: { errors: "Resource not found" }, status: :not_found
  end

  def handle_server_error(exception)
    Rails.logger.error "Server error: #{exception.message}"
    render json: { errors: "An unexpected error occurred" }, status: :internal_server_error
  end
end