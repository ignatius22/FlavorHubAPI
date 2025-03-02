# app/models/product_extra.rb
class ProductExtra < ApplicationRecord
  # == Constants ==
  DEFAULT_QUANTITY = 0.freeze
  DEFAULT_PRICE = 0.00.freeze
  EXTRA_TYPES = %w[add-on upgrade bundle accessory].freeze

  # == Associations ==
  belongs_to :product, inverse_of: :product_extras
  has_many :order_item_extras, dependent: :destroy, inverse_of: :product_extra
  has_many :order_items, through: :order_item_extras
  

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :product_id }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :extra_type, inclusion: { in: EXTRA_TYPES }, allow_nil: true

  # == Validations ==
  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :product_id, message: "already exists for this product" }
  validates :quantity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :extra_type,
            inclusion: { in: EXTRA_TYPES, message: "%{value} is not a valid extra type" },
            allow_nil: true

  # == Scopes ==
  scope :available, -> { where("quantity > 0") }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :by_type, ->(type) { where(extra_type: type) }
  scope :for_product, ->(product) { where(product: product) }
  scope :priced_above, ->(amount) { where("price > ?", amount) }

  # == Callbacks ==
  before_validation :set_defaults, on: :create

  # == Instance Methods ==
  # Checks if this extra is currently in stock
  def in_stock?
    quantity.positive?
  end

  # Adjusts quantity with validation
  def adjust_quantity!(amount)
    new_quantity = quantity + amount
    raise ArgumentError, "Quantity cannot be negative" if new_quantity.negative?
    update!(quantity: new_quantity)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to adjust quantity for ProductExtra ##{id}: #{e.message}"
    false
  end

  # Calculates total cost for a given quantity
  def total_cost(quantity = 1)
    (price * quantity).round(2)
  end

  # Checks if this extra is included in any orders
  def ordered?
    order_items.any?
  end

  private

  # == Private Methods ==
  # Sets default values for new records
  def set_defaults
    self.quantity ||= DEFAULT_QUANTITY
    self.price ||= DEFAULT_PRICE
    self.extra_type ||= EXTRA_TYPES.first if extra_type.blank?
  end
end