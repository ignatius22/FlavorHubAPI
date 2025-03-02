# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def initialize(user, target_user)
    @user = user
    @target_user = target_user
  end

  def index?
    @user.present?
  end

  def show?
    @user.present? && (@user == @target_user || @user.admin? || @user.super_admin?)
  end

  def create?
    @user.present?
  end

  def update?
    @user&.present? && (@user == @target_user || @user.admin? || @user.super_admin?)
  end

  def destroy?
    @user && (@user.super_admin? || (@user.admin? && @user != @target_user))
  end

  def show_profile?
    @user.present? && (@user == @target_user || @user.admin? || @user.super_admin?)
  end

  def update_profile?
    @user.present? && (@user == @target_user || @user.admin? || @user.super_admin?)
  end

  def favorites?
    @user.present?
  end

  def toggle_favorite?
    @user.present?
  end

  class Scope < Scope
    def resolve
      if @user&.super_admin?
        scope.all
      elsif @user&.admin?
        scope.where.not(role: 'super_admin')
      else
        scope.where(id: @user&.id)
      end
    end
  end
end