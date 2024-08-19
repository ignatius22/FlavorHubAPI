class Api::V1::ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: [:show, :update, :destroy]
    before_action :authorize_product, only: [:create, :update, :destroy]
  
    # GET /api/v1/products
    def index
      products = Product.visible.active
      render json: products, status: :ok
    end
  
    # GET /api/v1/products/:id
    def show
      render json: @product, status: :ok
    end

    def create
        @product = CreateProductService.new(product_params).call
    
        if @product.success?
          render json: @product.product, status: :created
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
    end
    
    # PATCH/PUT /api/v1/products/:id
    def update
      service = UpdateProductService.new(@product, product_params)
      result = service.call
  
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
        :title, :price, :delivery_fee, :duration, :image, :status, :visibility,
        product_extras_attributes: [:id, :name, :quantity, :_destroy]
      )
    end
  
    def authorize_product
       authorize Product
    end
end  