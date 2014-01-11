HireFire.configure do |config|
  config.environment      = nil # default in production is :heroku. default in development is :noop
  config.max_workers      = 2   # default is 1
  config.min_workers      = 0   # default is 0
  config.job_worker_ratio = [
      { :jobs => 1,   :workers => 1 },
      { :jobs => 15,  :workers => 2 }
    ]
end