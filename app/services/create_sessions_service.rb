# app/services/create_token_service.rb
class CreateSessionsService < ApplicationService
    def initialize(email, password)
      @user = User.find_by_email(email)
      @password = password
    end
  
    def call
      if @user&.authenticate(@password)
        token = JsonWebToken.encode(user_id: @user.id)
        { success: true, token: token, username: @user.username }
      else
        { success: false, errors: ["Unauthorized"] }
      end
    end
end