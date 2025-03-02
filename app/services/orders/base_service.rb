# app/services/orders/base_service.rb
module Orders
    class BaseService
      attr_reader :current_user, :errors
  
      def initialize(user)
        @current_user = user
        @errors = []
      end
  
      private
  
      def add_error(message)
        @errors << message
        false
      end
    end
end