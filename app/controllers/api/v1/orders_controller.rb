# app/controllers/api/v1/orders_controller.rb
module Api
    module V1
      class OrdersController < ApplicationController
        before_action :check_login
        before_action :set_order, only: [:show, :update, :destroy, :cancel, :ship]
        before_action :authorize_order, only: [:index, :show, :create, :update, :destroy, :cancel, :ship]
  
        def index
          @orders = policy_scope(Order)
          render_json(@orders, :ok)
        end
  
        def show
          render_json(@order, :ok)
        end
  
        def create
          @order = Order.new(order_params.merge(user: current_user))
          authorize @order
          if @order.save
            render_json(@order, :created)
          else
            render_error(@order.errors, :unprocessable_entity)
          end
        end
  
        def update
          if @order.update(order_params)
            render_json(@order, :ok)
          else
            render_error(@order.errors, :unprocessable_entity)
          end
        end
  
        def destroy
          @order.destroy!
          render json: { message: "Order destroyed successfully" }, status: :ok
        end
  
        def cancel
          if @order.update(status: 'cancelled')
            render_json(@order, :ok)
          else
            render_error(@order.errors, :unprocessable_entity)
          end
        end
  
        def ship
          if @order.update(status: 'shipped')
            SendOrderShippedJob.perform_async(@order.id) # Sidekiq job
            render_json(@order, :ok)
          else
            render_error(@order.errors, :unprocessable_entity)
          end
        end
  
        private
  
        def set_order
          @order = Order.find(params[:id])
        end
  
        def order_params
          params.require(:order).permit(:total_price, :status)
        end
  
        def authorize_order
          authorize(@order || Order)
        end
  
        def render_json(resource, status)
          render json: OrderSerializer.new(resource).serializable_hash.to_json, status: status
        end
      end
    end
  end