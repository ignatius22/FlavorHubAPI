  # app/services/orders/update_service.rb
  module Orders
    class UpdateService < BaseService
      def initialize(user, order, params)
        super(user)
        @order = order
        @params = params
      end
  
      def execute
        return @order if @order.update(permitted_params)
        @errors = @order.errors.full_messages
        nil
      end
  
      private
  
      def permitted_params
        @params.require(:order).permit(
          :total_price,
          :status,
          order_items_attributes: [:id, :product_id, :quantity, :price, :_destroy]
        )
      end
    end
end