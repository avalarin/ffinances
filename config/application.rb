require File.expand_path('../boot', __FILE__)

require 'rails/all'

require File.join(File.dirname(__FILE__), "redis.rb")
require File.join(File.dirname(__FILE__), "../lib", "captcha.rb")

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FamilyFinances
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)

    config.i18n.default_locale = :ru

    config.middleware.use Captcha::Middleware
  end
end
