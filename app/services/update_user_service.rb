class UpdateUserService < ApplicationService
  def initialize(current_user, user, user_params)
    @current_user = current_user
    @user = user
    @user_params = user_params
  end

  def call
    return OpenStruct.new(success?: false, errors: ["You are not authorized to update this user"]) unless authorized?

    if @user.update(@user_params)
      OpenStruct.new(success?: true, user: @user)
    else
      OpenStruct.new(success?: false, errors: @user.errors.full_messages)
    end
  end

  private

  def authorized?
    @current_user.super_admin? || (@current_user.admin? && @user != @current_user)
  end
end
