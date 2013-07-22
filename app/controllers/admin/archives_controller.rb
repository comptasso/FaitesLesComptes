# coding: utf-8

# FIXME : Il n'y ait plus vraiment d'accès à cette partie du programme
# 
# De toute façon, pg_dump ne fonctionne pas de l'intérieur de heroku.
# 
# Une option serait d'utiliser pg_dump d'un programme extérieur 
# en s'inspirant d'un gem du genre heroku_s3_pg_backup.
# 
# db = ENV['DATABASE_URL'].match(/postgres:\/\/([^:]+):([^@]+)@([^\/]+)\:[0-9]*\/(.+)/)
# system "PGPASSWORD=#{db[2]} pg_dump -Fc -i --username=#{db[1]} --host=#{db[3]} #{db[4]} > tmp/#{name}"
# 
# Il s'agit donc d'abord de récupérer la database_url puis de la parser avant de faire un dump
# Dès lors, il devient possible de faire 
# 
# system "PGPASSWORD=#{db[2]} pg_dump -n mon-schema --username=#{db[1]} --host=#{db[3]} #{db[4]} > tmp/#{name}"
# 
# En retirant -Fc on a un format texte standard et l'on devrait alors pouvoir changer le owner en celui que l'on souhaite
# avant de faire un pg_restore. Tout celà serait à valider.
# 
# On pourrait peut être copier pg_dump dans un répertoire lib pour qu'il devienne accessible; pas certain que ça marche.
#


class Admin::ArchivesController < Admin::ApplicationController

  
  def index
    @archives=@organism.archives.all
  end

  def edit
    @archive = Archive.find(params[:id])
  end

  def update
    @archive=@organism.archives.find(params[:id])
    if @archive.update_attributes(params[:archive])
      redirect_to admin_organism_archives_url(@organism)
    else
      render :edit
    end
  end

  def new
    @archive=@organism.archives.new
  end 

  def create
    
    @archive=@organism.archives.new(params[:archive])
    cookies[:download_file_token] = { :value =>params[:download_token_value_id], :expires => Time.now + 1800 }
    if @archive.save
      
      Tempfile.open(@organism.database_name, File.join(Rails.root, 'tmp')) do |f|
        dump_database(f)
        f.flush
        send_file f,
          :filename=>@archive.archive_filename,
          :disposition=>'attachment'
      end
    
    else
      flash[:alert]= "Une erreur s'est produite empêchant la sauvegarde de l'archive"
      render 'new'
    end
  end

  def destroy
    @archive=Archive.find(params[:id])
    if !@archive.destroy
      flash[:alert]= "Une erreur s'est produite empêchant la destruction de l'enregistrement"
    else
      flash[:notice]= "Enregistrement effacé"
    end
    redirect_to admin_organism_archives_url(@organism)
  end
  
  protected

  # crée le fichier représentant l'archive si besoin et retourne son emplacement
  # si l'adapter est sqlite3, le fichier existe déjà ; si postgres on crée un
  # fichier temporaire avec un dump
  # Retourne le fichier
  def dump_database(file)
    abc = ActiveRecord::Base.connection_config
    case abc[:adapter]
    when 'sqlite3'
      system("sqlite3 #{@organism.room.full_name} .dump > #{file.path}")
      # yield "#{Room.path_to_db}/#{organism.database_name}.sqlite3"
    when 'postgresql'
      system("pg_dump #{abc[:database]} -n #{@organism.database_name} > #{file.path}")
    end
  end

end
