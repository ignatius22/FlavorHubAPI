# app/models/order_item.rb
class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, 
                      numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, 
                    numericality: { greater_than_or_equal_to: 0 }
  validates :total, numericality: { greater_than_or_equal_to: 0 }, 
                    on: :update # Only validate total after calculation

  # Callbacks
  before_save :calculate_total

  # Instance Methods
  def unit_price
    product&.price || 0
  end

  private

  # Calculates the total cost based on quantity and unit price
  def calculate_total
    self.price ||= unit_price # Default to product price if not set
    self.total = (price * quantity).round(2) # Round to 2 decimal places for currency
  rescue StandardError => e
    Rails.logger.error "Error calculating total for OrderItem ##{id || 'new'}: #{e.message}"
    self.total = 0 # Fallback to avoid breaking save
  end
end