# coding: utf-8


# Ce fichier rake est destiné à gérer les migrations dans le cadre de plusieurs
# bases de données.

namespace :landlord do

  desc "Migration de toutes les bases de données de type sqlite3 dans organisms"
  task :migrate_each => :environment do
    ActiveRecord::Migration.verbose = true

    Room.all.each do |r|
      # on se connecte successivement à chacun d'eux
      r.connect_to_organism
      puts "migrating #{r.absolute_db_name}"  #File.basename(f)
      # et appel pour chacun de la fonction voulue
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)

    end
    # Retour à la configuration de base
    puts "retour à la connection prinicpale"
    default = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(default)
    puts 'migration de la base principale'
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
  end
end