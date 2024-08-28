class Api::V1::PasswordResetsController < ApplicationController
  before_action :set_user, only: [:update]

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_password_reset_token!
      PasswordResetMailer.with(user: user).reset_email.deliver_later
      render json: { message: 'Password reset instructions sent to your email.' }, status: :ok
    else
      render json: { errors: ['Email not found'] }, status: :not_found
    end
  end

  def update
    if @user && @user.password_reset_token == params[:token] && @user.password_token_valid?
      if @user.reset_password(params[:password])
        render json: { message: 'Password has been reset!' }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ['Invalid or expired token'] }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(password_reset_token: params[:token])
  end
end
