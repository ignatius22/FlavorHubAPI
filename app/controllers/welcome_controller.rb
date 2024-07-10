class WelcomeController < ApplicationController
    def index
      render json: {message: "WELCOME TO THE API!"}
    end
end
