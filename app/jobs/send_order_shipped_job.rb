# app/jobs/send_order_shipped_job.rb
class SendOrderShippedJob
    include Sidekiq::Job
  
    def perform(order_id)
      order = Order.find(order_id)
      OrderMailer.shipped(order).deliver_now
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Order ##{order_id} not found for shipping notification"
    end
end