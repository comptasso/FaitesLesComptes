# coding: utf-8


namespace :ocra do

def jc_create_dir(path)
    paths = path.split('/')
    return if paths.size == 0

    paths.size.times do |i|
      p = paths[0..i].join('/')
      d = File.expand_path(p)
      if File.directory?(d)
        puts "#{d} existe déjà; passage à l'étape suivante"
      else
       v = Dir.mkdir(d)
       puts(v == 0 ? "Création du répertoire #{d}" : "Echec de la création de #{d} - valeur de retour : #{v}")
      end
    end
  end

  desc "OCRA : création des répertoires et de la base de données"
  task :setup  => :environment do
    jc_create_dir("../db/#{Rails.env}/organisms")
    jc_create_dir("../logs")
    puts "Setup de la base #{Rails.env}"
    default = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(default)
    Rake::Task["db:schema:load"].invoke
  end

end