  # app/services/orders/status_change_service.rb
  module Orders
    class StatusChangeService < BaseService
      def initialize(user, order, new_status)
        super(user)
        @order = order
        @new_status = new_status
      end
  
      def execute
        return false unless valid_status?
  
        if @order.update(status: @new_status)
          process_side_effects
          return @order
        end
  
        @errors = @order.errors.full_messages
        nil
      end
  
      private
  
      def valid_status?
        Order::VALID_STATUSES.include?(@new_status) || 
          add_error("Invalid status: #{@new_status}")
      end
  
      def process_side_effects
        case @new_status
        when 'shipped'
          SendOrderShippedJob.perform_later(@order.id)
        when 'cancelled'
          # Add any cancel-specific logic here
        end
      end
    end
  end