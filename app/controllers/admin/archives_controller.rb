# coding: utf-8

# TODO : je crains qu'il n'y ait plus d'accès à cette partie du programme

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
    case ActiveRecord::Base.connection_config[:adapter]
    when 'sqlite3'
      system("sqlite3 #{@organism.full_name} .dump > #{file.path}")
      # yield "#{Room.path_to_db}/#{organism.database_name}.sqlite3"
    when 'postgresql'
      system("pg_dump faiteslescomptes -n #{@organism.database_name} > #{file.path}")
    end
  end

end
