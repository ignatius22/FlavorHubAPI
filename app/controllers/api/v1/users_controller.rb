# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      include Authenticable

      before_action :check_login, except: [:create]
      before_action :set_user, only: [:show, :update, :destroy, :show_profile, :update_profile]
      before_action :authorize_user, only: [:index, :show, :create, :update, :destroy, :show_profile, :update_profile]

      def index
        @users = policy_scope(User)
        render_json(@users)
      end

      def get_current_user
        render_json(current_user)
      end

      def recently_active_users
        @users = User.recently_active_users
        render_json(@users)
      rescue StandardError => e
        log_and_render_error("Failed to fetch recently active users: #{e.message}", :internal_server_error)
      end

      def active_users_with_orders
        @users = User.recently_active_users_with_orders
        render_json(@users)
      rescue StandardError => e
        log_and_render_error("Failed to fetch active users with orders: #{e.message}", :internal_server_error)
      end

      def show
        result = ShowUserService.call(@user)
        handle_service_response(result, :user)
      end

      def create
        result = CreateUserService.call(user_params, profile_params)
        handle_service_response(result, :user, :created)
      end

      def update
        authorize @user
        result = UpdateUserService.call(current_user, @user, user_params)
        handle_service_response(result, :user)
      end

      def show_profile
        result = ShowProfileService.call(@user)
        handle_service_response(result, :profile)
      end

      def update_profile
        result = UpdateProfileService.call(@user, profile_params)
        handle_service_response(result, :profile)
      end

      def destroy
        @user.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotDestroyed => e
        log_and_render_error("Failed to destroy user: #{e.message}", :unprocessable_entity)
      end

      private

      def set_user
        @user = User.find_by(id: params[:id])
        render_404 unless @user
      end

      def user_params
        params.require(:user).permit(:email, :username, :role, :password)
      end

      def profile_params
        params.require(:profile).permit(:first_name, :last_name, :bio, :avatar, :phone_number, :address)
      end

      def authorize_user
        authorize(@user || User)
      end

      def render_json(resource, status = :ok)
        render json: serialized_resource(resource), status: status
      end

      def serialized_resource(resource)
        case resource
        when User
          UserSerializer.new(resource).serializable_hash.to_json
        when Profile
          ProfileSerializer.new(resource).serializable_hash.to_json
        when Array
          serializer = resource.first.is_a?(User) ? UserSerializer : ProfileSerializer
          serializer.new(resource).serializable_hash.to_json
        else
          raise "Unsupported resource type for serialization: #{resource.class}"
        end
      end

      def handle_service_response(result, resource_type, success_status = :ok)
        if result.success?
          case resource_type
          when :user
            render_json(result.user, success_status)
          when :profile
            render_json(result.profile, success_status)
          else
            log_and_render_error("Invalid resource type: #{resource_type}", :unprocessable_entity)
          end
        else
          Rails.logger.warn "Service response failed for #{resource_type}: #{result.errors.join(', ')}"
          render_error(result.errors, :unprocessable_entity)
        end
      end

      def render_404
        render json: { errors: "User not found" }, status: :not_found
      end

      def log_and_render_error(message, status)
        Rails.logger.error message
        render json: { errors: message.split(': ').last || "An unexpected error occurred" }, status: status
      end
    end
  end
end