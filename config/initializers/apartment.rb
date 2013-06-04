# coding: utf-8

Apartment.configure do |config|
  config.excluded_models = ['User', 'Room']
  if Rails.env == 'test'
 #   config.database_names = Dir.entries('db/test').map {|db| db[/(\w*).sqlite3/]; $1}.reject {|db| db == nil}
    config.database_names = ['assotest1', 'assotest2']
  else
    config.database_names = lambda { Room.select('database_name').map {|r| r.database_name}}
  end
  
  config.prepend_environment = false
end