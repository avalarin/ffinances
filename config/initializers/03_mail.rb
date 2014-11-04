Rails.application.config.action_mailer.raise_delivery_errors = true
Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  :user_name => Settings.mail.smtp.user_name,
  :password => Settings.mail.smtp.password,
  :address => Settings.mail.smtp.host_name,
  :domain => Settings.mail.smtp.domain || Settings.mail.smtp.host_name,
  :port => Settings.mail.smtp.port,
  :authentication => Settings.mail.smtp.authentication,
  :enable_starttls_auto => true
}

ActionMailer::Base.default :from => Settings.mail.from