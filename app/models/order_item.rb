class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  before_save :calculate_total

  private

  def calculate_total
    self.total = price * quantity
  end
end
