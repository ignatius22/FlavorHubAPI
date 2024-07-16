class UpdateUserService < ApplicationService
    def initialize(user_id, user_params)
      @user_id = user_id
      @user_params = user_params
    end

    def call
        user = User.find_by(id: @user_id)
        return {success: false, errors: ["user not found"]} unless user
        if user.update(@user_params)
            {success:true, user: user}
        else
            {success: false, errors: user.errors.full_messages}
        end
    end

end