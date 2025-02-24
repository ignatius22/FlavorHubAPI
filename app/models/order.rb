# app/models/order.rb
class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_items

  # Enumerations
  enum status: {
    pending: 'pending',
    confirmed: 'confirmed',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled'
  }

  # Validations (aligned with your nullable schema)
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: statuses.keys }, allow_nil: true

  # Callbacks
  before_save :calculate_total_price, if: :order_items_changed?

  # Scopes
  scope :active, -> { where.not(status: 'cancelled') }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  # Public Methods
  def recalculate_total!
    calculate_total_price
    save!
  end

  # Checks if the order can be cancelled by the given user
  def cancellable?(current_user)
    raise ArgumentError, "User must be provided" unless current_user
    (pending? || confirmed?) && authorized_user?(current_user)
  end

  # Checks if the order can be shipped by the given user
  def shippable?(current_user)
    raise ArgumentError, "User must be provided" unless current_user
    confirmed? && (current_user.admin? || current_user.super_admin?)
  end

  # Updates the order status with role-based authorization
  def update_status!(new_status, current_user)
    case new_status
    when 'cancelled'
      unless cancellable?(current_user)
        raise AuthorizationError, "User #{current_user.id} cannot cancel this order"
      end
    when 'shipped'
      unless shippable?(current_user)
        raise AuthorizationError, "User #{current_user.id} cannot ship this order"
      end
      SendOrderShippedJob.perform_async(id) # Sidekiq job
    when *statuses.keys
      # No additional action
    else
      raise ArgumentError, "Invalid status: #{new_status}"
    end
    update!(status: new_status)
  end

  private

  # Calculates total price based on order items
  def calculate_total_price
    self.total_price = order_items.sum { |item| item.total || 0 }.round(2)
  rescue StandardError => e
    Rails.logger.error "Error calculating total price for Order ##{id || 'new'}: #{e.message}"
    self.total_price = 0
  end

  # Checks if order_items association has changed
  def order_items_changed?
    order_items.any?(&:changed?) || order_items.any?(&:new_record?) || order_items.any?(&:marked_for_destruction?)
  end

  # Determines if the user is authorized to perform actions
  def authorized_user?(current_user)
    current_user == user || current_user&.admin? || current_user&.super_admin?
  end

  # Custom exception for authorization failures
  class AuthorizationError < StandardError; end
end