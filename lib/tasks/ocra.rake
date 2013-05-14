# coding: utf-8


namespace :ocra do

  def jc_create_dir(path)
    paths = path.split('/')
    return if paths.size == 0

    paths.size.times do |i|
      p = paths[0..i].join('/')
      d = File.expand_path(p)
      if File.directory?(d)
        puts "#{d} existe; passage au fichier suivant"
      else
        v = Dir.mkdir(d)
        puts(v == 0 ? "Creation du repertoire #{d}" : "Echec de la creation de #{d} - valeur de retour : #{v}")
      end
    end
  end

  desc "OCRA : création des répertoires et de la base de données"
  task :setup  do
    
    jc_create_dir("db/ocra/organisms")
    jc_create_dir("logs")
    puts "Setup de la base ocra"
    default = Rails.application.config.database_configuration['ocra']
    ActiveRecord::Base.establish_connection(default)
    Rake::Task["db:schema:load"].invoke
  end



end