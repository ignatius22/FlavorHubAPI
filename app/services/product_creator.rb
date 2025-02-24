# app/services/product_creator.rb
class ProductCreator
  # Using keyword arguments for Result struct for clarity
  Result = Struct.new(:success?, :product, :errors, keyword_init: true)

  # Class method for cleaner invocation
  def self.call(product_params:, user:)
    new(product_params, user).call
  end

  def initialize(product_params, user)
    @product_params = product_params
    @user = user
  end

  def call
    # Early return if a duplicate exists
    if (existing_product = find_existing_product)
      return Result.new(
        success?: false,
        errors: ["Product with these attributes already exists"]
      )
    end

    # Build and save the product
    product = build_product
    if product.save
      Result.new(success?: true, product: product, errors: [])
    else
      Result.new(success?: false, product: nil, errors: product.errors.full_messages)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, product: nil, errors: [e.message])
  rescue StandardError => e
    Rails.logger.error "Unexpected error in CreateProductService: #{e.message}"
    Result.new(success?: false, product: nil, errors: ["An unexpected error occurred"])
  end

  private

  attr_reader :product_params, :user # Expose readers for internal use

  # Extract duplicate check into a separate method
  def find_existing_product
    Product.find_by(
      title: product_params[:title],
      price: product_params[:price],
      delivery_fee: product_params[:delivery_fee],
      duration: product_params[:duration]
    )
  end

  # Extract product building into a method
  def build_product
    Product.new(product_params.merge(user_id: user.id))
  end
end