class OrderSerializer
  include JSONAPI::Serializer
  attributes :user_id, :total_price, :status, :created_at, :updated_at

  has_many :order_items
  belongs_to :user
end