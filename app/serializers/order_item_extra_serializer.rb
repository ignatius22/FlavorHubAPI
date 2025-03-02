# app/serializers/order_item_extra_serializer.rb
class OrderItemExtraSerializer
    include JSONAPI::Serializer
    attributes :id, :quantity, :price_at_time, :total
  
    belongs_to :product_extra
end