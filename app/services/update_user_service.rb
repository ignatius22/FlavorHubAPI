class UpdateUserService < ApplicationService
    def initialize(user, user_params)
      @user = user
      @user_params = user_params
    end
  
    def call
      if @user.update(@user_params)
        OpenStruct.new(success?: true, user: @user)
      else
        OpenStruct.new(success?: false, errors: @user.errors.full_messages)
      end
    end
end
  