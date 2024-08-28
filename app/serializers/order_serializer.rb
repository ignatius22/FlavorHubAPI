class OrderSerializer
  include JSONAPI::Serializer
  attributes :order_number, :total_amount, :status, :created_at, :updated_at
  has_many :order_items
end
