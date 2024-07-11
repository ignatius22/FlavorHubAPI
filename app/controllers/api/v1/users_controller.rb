class Api::V1::UsersController < ApplicationController
    
   def show 
    user = User.find(params[:id])
    render json: user
   end

   def create
    @user = User.new(user_params)

      if @user.save
         render json: @user, status: :created
      else
         render json: @user.errors, status: :unprocessable_entity
      end
   end
   private

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:email, :password,:username)
  end
end
