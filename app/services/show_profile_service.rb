# app/services/show_profile_service.rb
class ShowProfileService < ApplicationService
    def initialize(user)
      @user = user
    end
  
    def call
      profile = @user.profile
      if profile
        { success: true, profile: profile }
      else
        { success: false, error: 'Profile not found' }
      end
    end
  end
  