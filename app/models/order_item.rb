class OrderItem < ApplicationRecord
  # == Constants ==
  DEFAULT_PRICE = 0.0.freeze

  # == Associations ==
  belongs_to :order, inverse_of: :order_items
  belongs_to :product
  has_many :order_item_extras, dependent: :destroy

  # == Validations ==
  validates :quantity,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :total,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true,
            on: :update

  # == Callbacks ==
  before_validation :set_default_price, on: :create
  before_save :calculate_total
  accepts_nested_attributes_for :order_item_extras, allow_destroy: true  # Add this

  # == Scopes ==
  scope :by_product, ->(product) { where(product: product) }
  scope :expensive, ->(threshold = 100) { where("price >= ?", threshold) }

  # == Instance Methods ==
  # Returns the product's unit price or a default if unavailable
  def unit_price
    product&.price || DEFAULT_PRICE
  end

  # Recalculates and persists the total
  def recalculate_total!
    calculate_total
    save!
  rescue StandardError => e
    Rails.logger.error "Failed to recalculate total for OrderItem ##{id}: #{e.message}"
    false
  end

  # Checks if this item contributes significantly to order total
  def significant?(threshold_percentage = 0.5)
    return false unless order&.total_price&.positive?
    (total.to_f / order.total_price) >= threshold_percentage
  end

  private

  # == Private Methods ==
  # Sets price from product if not specified
  def set_default_price
    self.price ||= unit_price
  end

  # Calculates total based on price and quantity
  def calculate_total
    self.total = (price * quantity).round(2)
  rescue StandardError => e
    Rails.logger.error "Total calculation failed for OrderItem ##{id || 'new'}: #{e.message}"
    self.total = DEFAULT_PRICE
  end
end