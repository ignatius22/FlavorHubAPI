class OrderItemSerializer
  include JSONAPI::Serializer
  attributes :quantity, :price, :total
  belongs_to :order
  belongs_to :product 
end
