require Rails.root.join("lib/captcha.rb")

Rails.application.config.middleware.use Captcha::Middleware