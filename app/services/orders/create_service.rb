  # app/services/orders/create_service.rb
  module Orders
    class CreateService < BaseService
      def initialize(user, params)
        super(user)
        @params = params
      end
  
      def execute
        order = current_user.orders.build(permitted_params)
        
        return order if order.save
        @errors = order.errors.full_messages
        nil
      end
  
      private
  
      def permitted_params
        @params.require(:order).permit(
          :total_price,
          :status,
          order_items_attributes: [:product_id, :quantity, :price]
        )
      end
    end
  end