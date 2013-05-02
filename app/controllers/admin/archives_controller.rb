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
      nam = @organism.full_name
      send_file nam, 
        :filename=>[File.basename(nam, '.sqlite3'), I18n.l(Time.now)].join(' ')+'.sqlite3',
        :disposition=>'attachment'
    else
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




end
