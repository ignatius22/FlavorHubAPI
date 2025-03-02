# app/models/order_item_extra.rb
class OrderItemExtra < ApplicationRecord
    # == Constants ==
    DEFAULT_PRICE = 0.00.freeze
  
    # == Associations ==
    belongs_to :order_item, inverse_of: :order_item_extras
    belongs_to :product_extra, inverse_of: :order_item_extras
  
    # == Validations ==
    validates :quantity,
              presence: true,
              numericality: { only_integer: true, greater_than: 0 }
    validates :price_at_time,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }
  
    # == Callbacks ==
    before_validation :set_price_at_time, on: :create
  
    # == Instance Methods ==
    def total
      (price_at_time * quantity).round(2)
    end
  
    private
  
    def set_price_at_time
      self.price_at_time ||= product_extra&.price || DEFAULT_PRICE
    end
end