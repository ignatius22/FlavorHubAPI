class Api::V1::ProductsController < ApplicationController
  before_action :check_login, only: [:create, :update, :destroy]
  before_action :set_product, only: [:show, :update, :destroy, :toggle_favorite]
  before_action :authorize_product!, only: [:create, :update, :destroy]
  # before_action :authorize_favorites_access!, only: [:favorites]

  # GET /api/v1/products
  def index
    # Apply ransack for filtering
    @q = Product.ransack(params[:q])
    products = @q.result

    render json: ProductSerializer.new(products).serializable_hash.to_json, status: :ok
  end

  # GET /api/v1/products/:id
  def show
    render json: ProductSerializer.new(@product).serializable_hash.to_json, status: :ok
  end

  # GET /api/v1/products/favorites
  def favorites
    if current_user
      favorite_products = current_user.favorite_products
      render json: ProductSerializer.new(favorite_products).serializable_hash.to_json, status: :ok
    else
      render json: { errors: 'User not authenticated' }, status: :unauthorized
    end
  end
  

  # POST /api/v1/products/:id/toggle_favorite
  def toggle_favorite
    favorite = current_user.favorites.find_by(product: @product)

    if favorite
      favorite.destroy
      render json: { message: 'Product unfavorited successfully' }, status: :ok
    else
      current_user.favorites.create!(product: @product)
      render json: { message: 'Product favorited successfully' }, status: :ok
    end
  end
  

  # POST /api/v1/products
  def create
    if %w[super_admin admin].include?(current_user.role)
      result = CreateProductService.new(product_params, current_user).call
  
      if result.success?
        render json: ProductSerializer.new(result.product).serializable_hash.to_json, status: :created
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
      render json: ProductSerializer.new(@product).serializable_hash.to_json, status: :ok
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

  # def authorize_favorites_access!
  #   unless current_user.super_admin? || current_user.admin?
  #     render json: { error: 'You are not authorized to view this resource' }, status: :forbidden
  #   end
  # end
end
