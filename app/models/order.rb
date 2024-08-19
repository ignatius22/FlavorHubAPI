class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum status: { pending: 'pending', confirmed: 'confirmed', shipped: 'shipped', delivered: 'delivered', cancelled: 'cancelled' }

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
end
