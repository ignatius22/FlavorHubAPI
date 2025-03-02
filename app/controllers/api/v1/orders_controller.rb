# app/controllers/api/v1/orders_controller.rb
module Api
    module V1
      class OrdersController < ApplicationController
        before_action :check_login, only: [:create, :update, :destroy]
        before_action :set_order, only: %i[show update destroy cancel ship]
        before_action :authorize_request, except: :create
  
        def index
          @orders = policy_scope(Order).order(created_at: :desc).includes(:user, order_items: :order_item_extras)
          render_success(@orders)
        end
  
        def show
          render_success(@order)
        end
  
        def create
          service = Orders::CreateService.new(current_user, params)
          @order = service.execute
  
          if @order
            authorize @order
            render_success(@order, :created)
          else
            render_error(service.errors, :unprocessable_entity)
          end
        end
  
        def update
          service = Orders::UpdateService.new(current_user, @order, params)
          if service.execute
            render_success(@order)
          else
            render_error(service.errors, :unprocessable_entity)
          end
        end
  
        def destroy
          service = Orders::DestroyService.new(current_user, @order)
          if service.execute
            render json: { message: "Order successfully deleted" }, status: :no_content
          else
            render_error(service.errors, :unprocessable_entity)
          end
        end
  
        def cancel
          process_status_change('cancelled')
        end
  
        def ship
          process_status_change('shipped')
        end
  
        private
  
        def set_order
          @order = Order.includes(:user, order_items: :order_item_extras).find(params[:id])
          authorize @order
        rescue ActiveRecord::RecordNotFound
          render_error("Order not found", :not_found)
        end
  
        def render_success(resource, status = :ok)
          render json: OrderSerializer.new(resource, include: [:user, "order_items.order_item_extras"]).serializable_hash, status: status
        end
  
        def authorize_request
          authorize(@order || Order)
        end
  
        def render_error(messages, status)
          render json: { errors: Array(messages) }, status: status
        end
  
        def process_status_change(new_status)
          service = Orders::StatusChangeService.new(current_user, @order, new_status)
          if service.execute
            render_success(@order)
          else
            render_error(service.errors, :unprocessable_entity)
          end
        end
      end
    end
end