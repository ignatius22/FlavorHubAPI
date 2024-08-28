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
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end
  
    def authorize_view!
      unless authorized_for_view?
        render json: { error: 'You are not authorized to view this profile' }, status: :forbidden
      end
    end
  
    def authorize_index_actions!
      return if authorized_for_index_actions?
      render json: { error: 'You are not authorized to access this resource' }, status: :forbidden
    end
  
    def authorized_for_user_actions?
      current_user&.super_admin? || current_user&.manager? || (current_user&.admin? && current_user.id != @user.id) || current_user.id == @user.id
    end
  
    def authorized_for_view?
      return false unless current_user
    
      current_user.super_admin? || 
        current_user.manager? || 
        current_user.admin? || 
        current_user.id == @user.id
    end
    
  
    def authorized_for_index_actions?
      current_user&.super_admin? || current_user&.manager? || current_user&.admin?
    end
end
  