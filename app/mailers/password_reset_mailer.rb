class PasswordResetMailer < ApplicationMailer
    default from: 'no-reply@yourdomain.com'
  
    def reset_email(user)
      @user = user
      @token = @user.password_reset_token
      @url = edit_api_v1_password_reset_url(@token, host: 'localhost', port: 3000)
      mail(to: @user.email, subject: 'Password Reset Instructions')
    end
end
  