class UserPolicy < ApplicationPolicy
  def update?
    user.super_admin? || (user.admin? && !user.eql?(record)) || !user.eql?(record)
  end

  def show?
    user.super_admin? || user.admin? || !user.eql?(record)
  end

  def favorites?
    user.present?
  end

  def toggle_favorite?
    user.present?
  end
  
  def destroy?
    user.super_admin? || (user.admin? && !user.eql?(record))
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      elsif user.admin?
        scope.where(id: user.id)
      else
        scope.where(id: user.id)
      end
    end
  end
end
