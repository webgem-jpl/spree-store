Resque.redis = ENV.fetch('REDIS_URL', 'localhost:6379/spree-store')
Resque.logger.level = Logger::DEBUG

Resque.before_fork = Proc.new { 
    ActiveRecord::Base.establish_connection

    # Create a new buffered logger
    Resque.logger = Logger.new(STDOUT)
    Resque.logger.level = Logger::INFO
    Resque.logger.debug "Resque Logger Initialized!"
  }