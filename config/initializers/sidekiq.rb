require Rails.root.join('config', 'initializers', 'redis').to_s

redis = { url: 'redis://' + ENV['REDIS_PORT_6379_TCP_ADDR'],
          namespace: "sco:#{Rails.env}:sidekiq" }

Sidekiq.configure_client do |config|
  config.redis = redis
end

if Sidekiq::Client.method_defined? :reliable_push!
  Sidekiq::Client.reliable_push!
end

Sidekiq.configure_server do |config|
  Sidekiq::Logging.logger.level = Logger::FATAL unless Rails.env.development?

  Rails.logger = Sidekiq::Logging.logger

  config.reliable_fetch!
  config.reliable_scheduler!
  config.redis = redis
end

Sidekiq.default_worker_options = {
  backtrace: false,
  # Set uniqueness lock expiration to 24 hours to balance preventing
  # duplicate jobs from running (if uniqueness time is too short)
  unique_job_expiration: 24.hours
}
