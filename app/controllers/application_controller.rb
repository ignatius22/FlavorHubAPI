class ApplicationController < ActionController::API
    include ResponseHandler
    include Authenticable
    include UserResponseHandler
    include Pundit::Authorization
    include ErrorHandler
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
        Rails.logger.warn "Unauthorized attempt by user: #{current_user&.id}"
        render json: { errors: "You are not authorized to perform this action" }, status: :forbidden
    end
    
end
