Resque.redis = ENV.fetch('REDIS_URL', 'localhost:6379')
Resque.logger.level = Logger::DEBUG
