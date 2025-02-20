# app/services/create_token_service.rb
class CreateSessionsService < ApplicationService
    def initialize(email, password)
      @user = User.find_by_email(email)
      @password = password
    end
  
    def call
      if @user&.authenticate(@password)
        @user.update(authenticated: true) # Update authentication status
        token = JsonWebToken.encode(user_id: @user.id)
        { success: true, 
          data:{
            token: token, 
            is_authenticate: @user.authenticated,
            role: @user.role,
            email: @user.email,
            username: @user.username
          }
        }
      else
        { success: false, errors: ["Unauthorized"] }
      end
    end
end