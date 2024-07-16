class ShowUserService < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def call
        user =  User.find_by(id: @user_id)
        if user
            {success: true, user: user}
        else
            {success: false, errors: user.errors.full_messages}
        end
    end
end