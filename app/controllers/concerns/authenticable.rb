module Authenticable
    # Returns the current authenticated user or nil if authentication fails
    def current_user
      return @current_user if @current_user
  
      auth_header = request.headers['Authorization']
      return nil if auth_header.blank?
  
      token = auth_header.split(' ').last
      begin
        decoded = JsonWebToken.decode(token)
        @current_user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn("User not found: #{e.message}")
        nil
      rescue JWT::DecodeError => e
        Rails.logger.warn("JWT Decode Error: #{e.message}")
        nil
      end
    end
  
    protected
  
    def check_login
      head :forbidden unless current_user
    end
end