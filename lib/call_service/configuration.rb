module CallService
  class Configuration
    attr_accessor :default_host, :default_region, :username, :password, :subscriber_realm, :queue_url, :services_host, :services_username, :services_password, :logger
  end
end
