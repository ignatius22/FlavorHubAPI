# app/services/update_profile_service.rb
class UpdateProfileService < ApplicationService
    def initialize(user, profile_params)
      @user = user
      @profile_params = profile_params
    end
  
    def call
      profile = @user.profile || @user.build_profile
      if profile.update(@profile_params)
        { success: true, profile: profile }
      else
        { success: false, errors: profile.errors.full_messages }
      end
    end
  end
  