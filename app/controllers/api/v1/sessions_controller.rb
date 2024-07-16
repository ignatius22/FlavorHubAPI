class Api::V1::SessionsController < ApplicationController
  def create
    result = CreateSessionsService.call(user_params[:email], user_params[:password])
    handle_response(result, :ok)
  end

  private

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:email, :password)
  end
end
