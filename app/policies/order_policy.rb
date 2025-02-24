# app/policies/order_policy.rb
class OrderPolicy < ApplicationPolicy
  # Pundit passes user (from current_user) and the order record
  def initialize(user, order)
    @user = user
    @order = order
  end

  def index?
    @user.present? # All authenticated users can list orders
  end

  def show?
    @user.present? && (@user == @order.user || @user.admin? || @user.super_admin?)
    # User can see their own order; admins can see all
  end

  def create?
    @user.present? # All authenticated users can create orders
  end

  def update?
    @user && (@user.admin? || @user.super_admin?) # Only admins can update
  end

  def destroy?
    @user && (@user.admin? || @user.super_admin?) # Only admins can destroy
  end

  def cancel?
    @user && (@order.cancellable? && (@user == @order.user || @user.admin? || @user.super_admin?))
    # User can cancel their own cancellable order; admins can cancel any
  end

  def ship?
    @user && (@order.confirmed? && (@user.admin? || @user.super_admin?))
    # Only admins can ship a confirmed order
  end

  class Scope < Scope
    def resolve
      if @user&.admin? || @user&.super_admin?
        scope.all # Admins see all orders
      else
        scope.where(user: @user) # Regular users see only their orders
      end
    end
  end
end