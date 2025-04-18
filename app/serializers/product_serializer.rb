class ProductSerializer
  include JSONAPI::Serializer

  attributes  :id, :title, :price, :delivery_fee, :duration, :image, :status, :visibility, :rating, :calories, :favorite
  
  has_many :product_extras, serializer: ProductExtraSerializer
end
