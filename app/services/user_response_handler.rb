module UserResponseHandler
  def handle_user_creation(result)
    if result[:success]
      render json: { user: UserSerializer.new(result[:user]).serialized_json }, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def handle_user_update(result)
    if result[:success]
      update_profile if profile_params_present?
      render json: { user: UserSerializer.new(result[:user]).serializable_hash.to_json }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def profile_params_present?
    params[:profile].present?
  end

  def update_profile
    profile_result = UpdateProfileService.call(@user, profile_params)
    handle_profile_update_response(profile_result)
  end

  def handle_profile_update_response(result)
    if result[:success]
      render json: { profile: ProfileSerializer.new(result[:profile]).serializable_hash.to_json }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :avatar, :bio, :phone_number, :address)
  end
end
