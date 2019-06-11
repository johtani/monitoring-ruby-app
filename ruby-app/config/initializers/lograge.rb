Rails.application.configure do
  config.lograge.enabled = true
  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    { timestamp: Time.now }
  end
end
