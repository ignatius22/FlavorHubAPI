# app/controllers/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern

  def current_user
    return @current_user if defined?(@current_user)

    token = extract_token_from_header
    return nil unless token

    decoded = decode_token(token)
    return nil unless decoded&.dig(:user_id)

    @current_user = User.find_by(id: decoded[:user_id])
  rescue JWT::DecodeError, StandardError
    nil
  end

  protected

  def check_login
    return true if current_user

    render json: { errors: "Not authenticated" }, status: :unauthorized
    false
  end

  private

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')

    auth_header.split(' ').last
  end

  def decode_token(token)
    JsonWebToken.decode(token)
  rescue JWT::DecodeError => e
    Rails.logger.warn "JWT Decode Error: #{e.message}"
    nil
  end
end