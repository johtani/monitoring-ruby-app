require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # For Elastic APM
    config.elastic_apm.service_name = 'MonitoringRubyDemo'

    # nomarl logging
    config.log_tags = [ :request_id ]

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = proc do |severity, time, progname, msg|
        request_id = msg.match(/\[(.*?)\].*/)[1] rescue ''
        entry = {
            severity: severity,
            progname: 'rails',
            request_id: request_id,
            time: time,
            message: msg,
        }
        "#{entry.to_json}\n"
      end
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
      config.colorize_logging = false
    else
      # default configure ..
    end
  end
end
