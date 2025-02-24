# app/controllers/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern

  def current_user
    return @current_user if defined?(@current_user)

    auth_header = request.headers['Authorization']
    unless auth_header.present? && auth_header.match?(/^Bearer\s/)
      Rails.logger.debug "No valid Bearer token found in header: #{auth_header.inspect}"
      return @current_user = nil
    end

    token = auth_header.split(' ').last
    Rails.logger.debug "Extracted token: #{token.inspect}"

    decoded = JsonWebToken.decode(token)
    unless decoded.is_a?(Hash) && decoded[:user_id].present?
      Rails.logger.warn "Invalid token payload: #{decoded.inspect}"
      return @current_user = nil
    end

    user_id = decoded[:user_id].to_i
    Rails.logger.debug "Looking up user with ID: #{user_id}"
    @current_user = User.find_by(id: user_id)
    unless @current_user
      Rails.logger.warn "User not found for ID: #{user_id}"
      @current_user = nil
    end

    @current_user
  rescue JWT::DecodeError => e
    Rails.logger.warn "JWT Decode Error: #{e.message}"
    @current_user = nil
  rescue StandardError => e
    Rails.logger.error "Unexpected error in current_user: #{e.message}\n#{e.backtrace.join("\n")}"
    @current_user = nil
  end

  protected

  def check_login
    unless current_user
      Rails.logger.warn "User not authenticated for action: #{action_name}"
      render json: { errors: "Not authenticated" }, status: :unauthorized
      return false # Ensure the action stops here
    end
    true # Continue if authenticated
  end
end