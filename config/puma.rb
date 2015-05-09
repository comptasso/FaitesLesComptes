# fichier repris des instructions de heroku pour passer à Puma.
# 
# Faute d'avoir vérifiér que le site est thread safe, nous restons à 1 
# ce qui est fixé par le fichier .env en local.
#

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  # ActiveRecord::Base.establish_connection
  
  # Valid on Rails up to 4.1 the initializer method of setting `pool` size
  
  # n'ayant pas défini MAX_THRAEDS, je mets le pool de connection à 5
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['pool'] = 5 #ENV['MAX_THREADS'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
end