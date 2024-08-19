class CreateProductService
    Result = Struct.new(:success?, :product, :errors)
  
    def initialize(product_params)
      @product_params = product_params
    end
  
    def call
      product = Product.new(product_params)
  
      if product.save
        Result.new(true, product, [])
      else
        Result.new(false, nil, product.errors.full_messages)
      end
    end
  
    private
  
    attr_reader :product_params
end