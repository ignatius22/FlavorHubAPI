# app/services/update_product_service.rb
class UpdateProductService
  Result = Struct.new(:success?, :product, :errors, keyword_init: true)

  def self.call(product:, product_params:)
    new(product, product_params).call
  end

  def initialize(product, product_params)
    @product = product
    @product_params = product_params
  end

  def call
    if @product.update(product_params)
      Result.new(success?: true, product: @product, errors: [])
    else
      Result.new(success?: false, product: nil, errors: @product.errors.full_messages)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, product: nil, errors: [e.message])
  rescue StandardError => e
    Rails.logger.error "Unexpected error in UpdateProductService: #{e.message}"
    Result.new(success?: false, product: nil, errors: ["An unexpected error occurred"])
  end

  private

  attr_reader :product, :product_params
end