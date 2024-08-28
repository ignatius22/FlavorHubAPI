class CreateProductService
  Result = Struct.new(:success?, :product, :errors)

  def initialize(product_params, user)
    @product_params = product_params
    @user = user
  end

  def call
    # Check for existing product with the same attributes
    existing_product = Product.find_by(
      title: product_params[:title],
      price: product_params[:price],
      delivery_fee: product_params[:delivery_fee],
      duration: product_params[:duration]
    )

    if existing_product
      Result.new(false, nil, ["Product with these attributes already exists"])
    else
      product = Product.new(product_params.merge(user_id: @user.id))

      if product.save
        Result.new(true, product, [])
      else
        Result.new(false, nil, product.errors.full_messages)
      end
    end
  end

  private

  attr_reader :product_params, :user
end
