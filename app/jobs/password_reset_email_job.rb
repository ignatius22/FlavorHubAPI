class PasswordResetEmailJob < ApplicationJob
    queue_as :default
  
    def perform(user)
      PasswordResetMailer.with(user: user).reset_email.deliver_now
    end
end
  