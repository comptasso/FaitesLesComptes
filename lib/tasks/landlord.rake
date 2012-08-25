# coding: utf-8


# Ce fichier rake est destiné à gérer les migrations dans le cadre de plusieurs
# bases de données.

namespace :landlord do

  desc "Migration de toutes les bases de données de type sqlite3 dans organisms"
  task :migrate_each => :environment do
    ActiveRecord::Migration.verbose = true
    # identification de tous les fichiers de type sqlite3
    Dir[Rails.root.join("db/#{Rails.env}/organisms/*.sqlite3")].each do |f|
      puts "migrating #{f}"  #File.basename(f)
      # on se connecte successivement à chacun d'eux
      ActiveRecord::Base.establish_connection(adapter:'sqlite3', database:f)
      # et appel pour chacun de la fonction voulue
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)

    end
    # Retour à la configuration de base
    puts "retour à la connection de base pour #{Rails.env}"
    default = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(default)
    puts 'migration de la base principale'
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
  end
end