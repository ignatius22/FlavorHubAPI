module Authenticable
    # Returns the current authenticated user or nil if authentication fails
    def current_user
      return @current_user if @current_user
    
      auth_header = request.headers['Authorization']
      Rails.logger.debug("Authorization header: #{auth_header.inspect}")
    
      return nil if auth_header.blank?
    
      token = auth_header.split(' ').last
      Rails.logger.debug("Token: #{token.inspect}")
    
      begin
        decoded = JsonWebToken.decode(token)
        Rails.logger.debug("Decoded token: #{decoded.inspect}")
    
        if decoded && decoded[:user_id]
          @current_user = User.find(decoded[:user_id])
        else
          Rails.logger.warn("Invalid token payload: #{decoded.inspect}")
          @current_user = nil
        end
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn("User not found: #{e.message}")
        @current_user = nil
      rescue JWT::DecodeError => e
        Rails.logger.warn("JWT Decode Error: #{e.message}")
        @current_user = nil
      end
    end
    
  
    protected
  
    def check_login
      unless current_user
        Rails.logger.warn("User not authenticated")
        render json: { error: 'Not authenticated' }, status: :forbidden
      end
    end
end