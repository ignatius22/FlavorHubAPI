class ProductPolicy < ApplicationPolicy
  def create?
    Rails.logger.debug "User: #{user&.inspect}, Role: #{user&.role}"
    user && (user.role == "admin" || user.role == "super_admin")
  end

  def update?
    create? # Same permissions as create
  end

  def archive?
    create? # Same permissions as create
  end

  def unarchive?
    admin_or_super_admin?
  end

  def delete_permanently?
    user&.super_admin? # Only super_admins can permanently delete
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role == "admin" || user.role == "super_admin"
        scope.all
      else
        scope.none # Non-admin users should not see any products
      end
    end
  end
end
