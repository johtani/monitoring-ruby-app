Rails.application.configure do
  #path = "#{Rails.root}/log/lograge_#{Rails.env}.log"
  config.lograge.enabled = true
  config.lograge.keep_original_rails_log = true
  #config.lograge.logger = ActiveSupport::Logger.new STDOUT
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
  config.lograge.formatter = Lograge::Formatters::Json.new
  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    {
        timestamp: Time.now,
        :params => event.payload[:params],
        :level => event.payload[:level],
        exception: event.payload[:exception],
        exception_object: event.payload[:exception_object],
        backtrace: event.payload[:exception_object].try(:backtrace)
    }
  end
end
