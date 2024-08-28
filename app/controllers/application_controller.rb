class ApplicationController < ActionController::API
    include ResponseHandler
    include Authenticable
    include UserResponseHandler
end
