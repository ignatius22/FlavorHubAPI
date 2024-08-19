class Api::V1::UsersController < ApplicationController
  include Authorization

  before_action :set_user, only: %i[update show destroy show_profile update_profile]

  def index
    @recently_active_users = User.recently_active_users
    render json: @recently_active_users
  end

  def active_users_with_orders
    @recently_active_users_with_orders = User.recently_active_users_with_orders
    render json: @recently_active_users_with_orders
  end

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
    handle_update_response(result)
  end

  def show_profile
    result = ShowProfileService.call(@user)
    handle_response(result, :ok)
  end

  def update_profile
    result = UpdateProfileService.call(@user, profile_params)
    handle_response(result, :ok)
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :role, :password)
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :bio, :avatar, :phone_number, :address)
  end

  def set_user
    @user = User.find_by(id: params[:id])
    render json: { error: 'User not found' }, status: :not_found unless @user
  end

  def handle_update_response(result)
    if result.success?
      render json: result.user, status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end
end
