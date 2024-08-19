# app/controllers/concerns/authorization.rb
module Authorization
    extend ActiveSupport::Concern
  
    included do
      before_action :authorize_user!, only: %i[update destroy]
      before_action :authorize_view!, only: %i[show show_profile]
      before_action :authorize_index_actions!, only: %i[index active_users_with_orders]
    end
  
    private
  
    def authorize_user!
      return if authorized_for_user_actions?
  
      Rails.logger.debug "Authorization failed for update/delete: #{current_user&.id} cannot modify #{@user.id}"
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end
  
    def authorize_view!
      return if authorized_for_view?
  
      Rails.logger.debug "Authorization failed for viewing profile: #{current_user&.id} cannot view #{@user.id}"
      render json: { error: 'You are not authorized to view this profile' }, status: :forbidden
    end
  
    def authorize_index_actions!
      return if authorized_for_index_actions?
  
      Rails.logger.debug "Authorization failed for index actions: #{current_user&.id} cannot access index actions"
      render json: { error: 'You are not authorized to access this resource' }, status: :forbidden
    end
  
    def authorized_for_user_actions?
      current_user&.super_admin? || current_user&.manager? || (current_user&.admin? && current_user.id != @user.id) || current_user.id == @user.id
    end
  
    def authorized_for_view?
      current_user&.super_admin? || current_user&.manager? || (current_user&.admin? && current_user.id != @user.id) || current_user.id == @user.id
    end
  
    def authorized_for_index_actions?
      current_user&.super_admin? || current_user&.manager? || current_user&.admin?
    end
end
  