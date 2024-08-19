class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  default from: 'no-reply@yourdomain.com'
  layout 'mailer'
end