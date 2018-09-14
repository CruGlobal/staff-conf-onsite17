require Rails.root.join('config', 'initializers', 'redis')

Rails.application.config.session_store(
  :redis_store,
  servers: [{
    host: Redis.current.client.host,
    port: Redis.current.client.port,
    db: 2,
    namespace: 'sco:session:'
  }],
  expire_after: 8.hours
)
