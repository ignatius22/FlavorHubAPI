# app/models/order.rb
class Order < ApplicationRecord
  # == Constants ==
  STATUSES = {
    pending: "pending",
    confirmed: "confirmed",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }.freeze

  # == Associations ==
  belongs_to :user
  has_many :order_items, 
           dependent: :destroy, 
           inverse_of: :order, 
           autosave: true
  has_many :products, through: :order_items

  # == Enumerations ==
  enum status: STATUSES

  # == Validations ==
  validates :total_price, 
            numericality: { greater_than_or_equal_to: 0 }, 
            allow_nil: true
  validates :status, 
            inclusion: { in: STATUSES.keys }, 
            allow_nil: true

  # == Callbacks ==
  before_save :calculate_total_price, if: :should_recalculate_total?
  accepts_nested_attributes_for :order_items, allow_destroy: true  # Add this

  # Debug callback
  before_validation do
    puts "Status before validation: #{status}"
  end

  # == Scopes ==
  scope :active, -> { where.not(status: :cancelled) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  # == Class Methods ==
  class << self
    # Find orders that need shipping attention
    def need_shipping_attention
      confirmed.recent.where("created_at < ?", 2.days.ago)
    end
  end

  # == Instance Methods ==
  # Recalculates and persists the total price
  def recalculate_total!
    calculate_total_price
    save!
  rescue StandardError => e
    Rails.logger.error "Failed to recalculate total for Order ##{id}: #{e.message}"
    false
  end

  # Determines if order can be cancelled
  def cancellable_by?(user)
    return false unless valid_user?(user)
    pending? || confirmed?
  end

  # Determines if order can be shipped
  def shippable_by?(user)
    return false unless valid_user?(user)
    confirmed? && user_has_shipping_privileges?(user)
  end

  # Updates status with authorization and side effects
  def update_status!(new_status, current_user)
    raise ArgumentError, "Invalid status: #{new_status}" unless STATUSES.key?(new_status)

    transaction do
      case new_status
      when "cancelled"
        authorize_cancellation!(current_user)
      when "shipped"
        authorize_shipping!(current_user)
        schedule_shipping_notification
      end
      update!(status: new_status)
    end
    self
  rescue AuthorizationError, ArgumentError => e
    errors.add(:status, e.message)
    raise
  end

  private

  # == Private Methods ==
  # Calculates total price from order items
  def calculate_total_price
    self.total_price = order_items.sum(&:total_price).round(2)
  rescue StandardError => e
    Rails.logger.error "Total calculation failed for Order ##{id || 'new'}: #{e.message}"
    self.total_price = 0
  end

  # Determines if total needs recalculation
  def should_recalculate_total?
    order_items_changed? || total_price.nil?
  end

  # Checks if order_items have changed
  def order_items_changed?
    order_items.any? { |item| item.changed? || item.new_record? || item.marked_for_destruction? }
  end

  # Validates user presence
  def valid_user?(user)
    user.present? || raise(ArgumentError, "User must be provided")
  end

  # Checks user's shipping privileges
  def user_has_shipping_privileges?(user)
    user.admin? || user.super_admin?
  end

  # Authorization for cancellation
  def authorize_cancellation!(user)
    return if cancellable_by?(user)
    raise AuthorizationError, "User #{user.id} not authorized to cancel order ##{id}"
  end

  # Authorization for shipping
  def authorize_shipping!(user)
    return if shippable_by?(user)
    raise AuthorizationError, "User #{user.id} not authorized to ship order ##{id}"
  end

  # Schedules shipping notification
  def schedule_shipping_notification
    SendOrderShippedJob.perform_later(id)
  end

  # == Nested Classes ==
  class AuthorizationError < StandardError; end
end