module Orders
  class CreateService < BaseService
    def initialize(user, params)
      super(user)
      @params = params
    end

    def execute
      order = current_user.orders.build(@params)  # Use params directly
      puts "Order status before save: #{order.status}"
      return order if order.save
      @errors = order.errors.full_messages
      puts "Errors: #{@errors}"
      nil
    end
  end
end