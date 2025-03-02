  
  # app/services/orders/destroy_service.rb
  module Orders
    class DestroyService < BaseService
      def initialize(user, order)
        super(user)
        @order = order
      end
  
      def execute
        @order.destroy!
        true
      rescue ActiveRecord::RecordNotDestroyed
        @errors = @order.errors.full_messages
        false
      end
    end
  end