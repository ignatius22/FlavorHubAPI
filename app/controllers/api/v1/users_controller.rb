class Api::V1::UsersController < ApplicationController
   before_action :set_user, only: %i[update show destroy show_profile update_profile]
   before_action :check_owner, only: %i[update destroy update_profile]

    
   def show
      result = ShowUserService.call(@user)
      handle_response(result, :ok, :user)
   end
  
   def create
      result = CreateUserService.call(user_params, profile_params)
      handle_user_creation(result)
   end
  
    def update
      result = UpdateUserService.call(@user, user_params)
      handle_user_update(result)
    end
  
    def show_profile
      result = ShowProfileService.call(@user)
      handle_response(result, :ok)
    end
  
    def update_profile
      result = UpdateProfileService.call(@user, profile_params)
      handle_response(result, :ok)
    end
   
    def destroy
      @user.destroy
      head :no_content
    end
    
   private

    def user_params
      params.require(:user).permit(:email, :password, :username)
    end

    def set_user
      @user = User.find_by(id: params[:id])
      head :not_found unless @user
    end

    def check_owner
    head :forbidden unless @user.id == current_user&.id
    end

end
