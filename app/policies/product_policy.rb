class ProductPolicy < ApplicationPolicy
  def create?
    Rails.logger.debug "User: #{user&.inspect}, Role: #{user&.role}"
    user && (user.role == "admin" || user.role == "super_admin")
  end

  def update?
    create? # Same permissions as create
  end

  def destroy?
    create? # Same permissions as create
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
