class OrderItemSerializer
  include JSONAPI::Serializer
  attributes :id, :product_id, :quantity, :price, :total

  belongs_to :product
  has_many :order_item_extras
end
