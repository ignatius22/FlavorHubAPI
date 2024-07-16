class CreateUserService < ApplicationService
    def initialize(user_params, profile_params)
        @user_params = user_params
        @profile_params = profile_params
    end
    
      def call
        user = User.new(@user_params)
        if user.save
          create_profile(user) if @profile_params.present?
          { success: true, user: user }
        else
          { success: false, errors: user.errors.full_messages }
        end
      end
    
      private
    
      def create_profile(user)
        profile = user.build_profile(@profile_params)
        unless profile.save
          { success: false, errors: profile.errors.full_messages }
        end
      end
end