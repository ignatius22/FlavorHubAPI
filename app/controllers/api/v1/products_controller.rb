class Api::V1::ProductsController < ApplicationController
  before_action :check_login, only: [:create, :update, :destroy]
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authorize_product!, only: [:create, :update, :destroy]

  # GET /api/v1/products
  def index
    products = Product.visible.active
    render json: products, status: :ok
  end

  # GET /api/v1/products/:id
  def show
    render json: @product.as_json(
      include: :product_extras,
      methods: [:formatted_created_at, :formatted_updated_at]
    ), status: :ok
  end

  # POST /api/v1/products
  def create
    if %w[super_admin admin].include?(current_user.role)
      # Initialize the service with both product_params and current_user
      result = CreateProductService.new(product_params, current_user).call
  
      if result.success?
        render json: result.product.as_json(include: :product_extras), status: :created
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    else
      render json: { errors: ['Unauthorized'] }, status: :forbidden
    end
  end
  
  

  # PATCH/PUT /api/v1/products/:id
  def update
    result = UpdateProductService.new(@product, product_params).call

    if result.success?
      render json: @product, status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    @product.update(status: 'archived')
    render json: { message: "Product archived successfully" }, status: :ok
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :title, :price, :delivery_fee, :duration, :image, :status, :visibility, :rating, :calories,
      product_extras_attributes: [:id, :name, :quantity, :_destroy]
    )
  end

  def authorize_product!
    unless current_user.super_admin? || current_user.admin?
      Rails.logger.debug "Authorization failed: #{current_user.id} cannot perform this action"
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end
  end
end
