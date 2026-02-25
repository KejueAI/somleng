CallService.configure do |config|
  config.default_host = Rails.configuration.app_settings.fetch(:call_service_default_host)
  config.default_region = Rails.configuration.app_settings.fetch(:call_service_default_region)
  config.username = Rails.configuration.app_settings.fetch(:call_service_username)
  config.password = Rails.configuration.app_settings.fetch(:call_service_password)
  config.queue_url = Rails.configuration.app_settings.fetch(:call_service_queue_url)
  config.services_host = Rails.configuration.app_settings.fetch(:services_host, nil)
  config.services_username = Rails.configuration.app_settings.fetch(:services_username)
  config.services_password = Rails.configuration.app_settings.fetch(:services_password, nil)
  config.logger = Rails.logger
  config.subscriber_realm = "somleng.org"
end
