module Api
  module V1
      class ProductsController < ApplicationController
        before_action :check_login, only: [:create, :update, :archive, :favorites]  # Updated destroy to archive
        before_action :set_product, only: [:show, :update, :archive, :unarchive, :delete_permanently, :toggle_favorite]
        before_action :authorize_product!, only: [:create, :update, :archive]  # Updated destroy to archive
        

        def index
          @q = Product.ransack(params[:q])
          render_json(@q.result, :ok)
        end

        def show
          render_json(@product, :ok)
        end

        def favorites
          render_json(current_user.favorite_products, :ok)
        end

        def toggle_favorite
          result = ToggleFavoriteService.call(user: current_user, product: @product)
          render json: { message: result.message }, status: :ok # Direct render, not render_json
        end

        def create
          @product = Product.new(permitted_params)
          authorize @product

          result = CreateProductService.call(
            product_params: permitted_params,
            user: current_user
          )

          if result.success?
            render_json(result.product, :created)
          else
            render_error(result.errors, :unprocessable_entity)
          end
        end
        
        def update
          result = UpdateProductService.new(@product, permitted_params).call

          if result.success?
            render json: ProductSerializer.new(@product).serializable_hash.to_json, status: :ok
          else
            render_error(result.errors, :unprocessable_entity)
          end
        end

        def archive
          if @product.update(status: 'archived')
            render json: { message: "Product archived successfully" }, status: :ok
          else
            render_error(@product.errors.full_messages, :unprocessable_entity)
          end
        end

        def unarchive
          if @product.status == 'archived'
            @product.update(status: 'active')
            render json: { message: "Product unarchived successfully" }, status: :ok
          else
            render_error("Product is not archived", :unprocessable_entity)
          end
        end

        def delete_permanently
          if @product.destroy
            render json: { message: "Product permanently deleted" }, status: :no_content
          else
            render_error(@product.errors.full_messages, :unprocessable_entity)
          end
        end

        private

        def set_product
          @product = Product.includes(:product_extras).find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_error("Product not found", :not_found)
        end

        def permitted_params
          params.require(:product).permit(
            :title, :price, :delivery_fee, :duration, :image,
            :status, :visibility, :rating, :calories,
            product_extras_attributes: [:id, :name, :quantity, :_destroy]
          )
        end

        def render_json(resource, status)
          render json: ProductSerializer.new(resource).serializable_hash.to_json, status: status
        end

        def authorize_product!
          authorize(@product || Product)
        end
      end
  end
end

