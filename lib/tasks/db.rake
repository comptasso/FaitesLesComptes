# TrouvÃ© sur le site suivant
# http://blog.nistu.de/2012/03/25/multi-database-setup-with-rails-and-rspec
# Modif des tÃ¢che db
#


namespace :db do
  

  # task rajoutÃ©e pour avoir des tables test sur 3 bases de donnÃ©es
  # est appelÃ©e notamment par db:test:prepare
  namespace :test do
    desc 'Pour purger et charger les schema des bases de test assotest1 et assotest2'
    task :load_schema do
      # effacement du fichier
      File.open('db/test/organisms/assotest1.sqlite3', 'wb') {}
      # like db:test:load_schema
      puts 'migration de la table assotest1'
      ActiveRecord::Base.establish_connection('assotest1')
      ActiveRecord::Schema.verbose = true
      load("#{Rails.root}/db/schema.rb")

      puts 'migration de la table assotest2'
      File.open('db/test/organisms/assotest2.sqlite3', 'wb') {}
      ActiveRecord::Base.establish_connection('assotest2')
      ActiveRecord::Schema.verbose = true
      load("#{Rails.root}/db/schema.rb")

      puts 'migration de la table principale'
      Rails.logger.debug 'migration de la table principale'
      File.open('db/test.sqlite3', 'wb') {}
      ActiveRecord::Base.establish_connection('test')
      ActiveRecord::Schema.verbose = true
      load("#{Rails.root}/db/schema.rb")
    end


  end
end
