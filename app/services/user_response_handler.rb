module UserResponseHandler
    def handle_user_creation(result)
      if result[:success]
        render json: { user: result[:user] }, status: :created
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end
  
    def handle_user_update(result)
      if result[:success]
        update_profile if profile_params_present?
        render json: { user: result[:user] }, status: :ok
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end
  
    private
  
    def profile_params_present?
      params[:profile].present?
    end
    
    def create_profile(user)
        profile = user.build_profile(profile_params)
        unless profile.save
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
    end
    
    def update_profile
        profile_result = UpdateProfileService.call(@user, profile_params)
        handle_response(profile_result, :ok, 'profile')
    end

    def profile_params
        params.require(:profile).permit(:first_name, :last_name, :avatar,:bio,:phone_number,:address)
    end
end
  