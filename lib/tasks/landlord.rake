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


  # TODO : A tester mieux (n'a fonctionné qu'une fois et
  # la table principale a subi un double rollback
  # C'est pourquoi, j'ai déplacé default en haut de cette tâche car c'est peut
  # être là que l'on note le numéro de la migration actuelle.
  desc "Rollback de toutes les bases de données de type sqlite3 dans organisms"
  task :rollback_each => :environment do
    default = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Migration.verbose = true
    Room.all.each do |r|
      # on se connecte successivement à chacun d'eux
      r.connect_to_organism
      puts "migrating #{r.absolute_db_name}"  #File.basename(f)
      # et appel pour chacun de la fonction voulue
      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths)

    end
    # Retour à la configuration de base
    puts "retour à la connection prinicpale"
    ActiveRecord::Base.establish_connection(default)
    puts 'migration de la base principale'
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths)
  end

# N'a pas de sens car rake db:test:prepare charge les schémas et ça suffit
  #  namespace :test do
#    desc 'Rollback des bases de test assotest1 et assotest2'
#    task :rollback_each => :environment do
#      ActiveRecord::Schema.verbose = true
#      default = Rails.application.config.database_configuration('test')
#      ['assotest1', 'assotest2'].each do |base|
#        puts "rollback de #{base}"
#        ActiveRecord::Base.establish_connection(base)
#        ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths)
#      end
#      puts "rollback de la base test"
#      ActiveRecord::Base.establish_connection(default)
#      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths)
#    end
#  end
end