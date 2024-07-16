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
  
    def destroy
      @user.destroy
      head :no_content
    end
  
    def show_profile
      profile = @user.profile
      if profile
        render json: { profile: profile }, status: :ok
      else
        render json: { error: 'Profile not found' }, status: :not_found
      end
    end
  
    def update_profile
      profile = @user.profile || @user.build_profile
      if profile.update(profile_params)
        render json: { profile: profile }, status: :ok
      else
        render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end
   
   private

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:email, :password, :username)
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :avatar,:bio,:phone_number,:address)
  end


 def handle_user_creation(result)
   if result[:success]
     render json: { user: result[:user] }, status: :created
   else
     render json: { errors: result[:errors] }, status: :unprocessable_entity
   end
 end

 def handle_user_update(result)
   if result.success?
     update_profile if profile_params_present?
     render json: { user: result.data }, status: :ok
   else
     render json: { errors: result.errors }, status: :unprocessable_entity
   end
 end

 def profile_params_present?
   params[:profile].present?
 end


 def create_profile(user)
   profile = user.build_profile(profile_params)
   unless profile.save
     render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
   end
 end

 def set_user
   @user = User.find_by(id: params[:id])
   head :not_found unless @user
 end

  def check_owner
   head :forbidden unless @user.id == current_user&.id
  end

end
