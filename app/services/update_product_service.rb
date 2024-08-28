class UpdateProductService
    Result = Struct.new(:success?, :product, :errors)
  
    def initialize(product, product_params)
      @product = ProductSerializer
      @product_params = product_params
    end
  
    def call
      if @product.update(@product_params)
        Result.new(true, @product, [])
      else
        Result.new(false, @product, @product.errors.full_messages)
      end
    end
  
    private
  
    attr_reader :product, :product_params
end
  