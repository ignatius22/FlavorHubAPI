class ApplicationController < ActionController::API
    include ResponseHandler
    include Authenticable
end
