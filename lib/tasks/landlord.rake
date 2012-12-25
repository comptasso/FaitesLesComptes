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

    Rake::Task["db:schema:dump"].invoke
    Rake::Task["db:test:prepare"].invoke
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


  

  
  desc "Création des répertoires et des bases de données"
  task :create_directories => :environment do
    d = "../db/#{Rails.env}"
    if File.directory?(d)
      puts "#{d} existe déjà; passage à l'étape suivante"
    else
      puts "Création du répertoire #{d}"
      Dir.mkdir(d)
    end

    puts "Setup de la base #{Rails.env}"
    default = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(default)
    Rake::Task["db:schema:load"].invoke


    puts 'Création du sous répertoire /organisms, lequel recevra les bases individuelles des différents organismes'
    d = "../db/#{Rails.env}/organisms"
    if File.directory?(d)
      puts  "#{d} existe déjà; passage à l'étape suivante"
    else
      puts "Création du répertoire #{d}"
      Dir.mkdir(d)
    end

  end

  # tâche provisoire pour la modification du modèle Organisme 
  # avec un champ nomenclature.
  desc "Remplissage du champ nomenclature"
  task :fill_nomenclature => :environment do
    Room.all.each do |r|
      # on se connecte successivement à chacun d'eux
      puts "fill nomenclature pour #{r.absolute_db_name}"
      r.look_for do
        o = Organism.first
        o.send(:read_nomenclature)
        o.save
      end
    end
  end
end