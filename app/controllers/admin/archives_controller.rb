# coding: utf-8

# Voir la classe restore pour les différentes opérations de restauration d'un fichier
#
#

class Admin::ArchivesController < Admin::ApplicationController
  def index
    @archives=@organism.archives.all 
  end

  def edit
    @archive=@organism.archives.find(params[:id])
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
      nam = "#{Rails.root}/#{@organism.base_name}"
      send_file nam, 
        :filename=>[File.basename(nam, '.sqlite3'), Time.now].join(' ')+'.sqlite3',
        :disposition=>'attachment'
    else
      render 'new'
    end
  end

  def destroy
    @archive=@organism.archives.find(params[:id])
    if !@archive.destroy
      flash[:alert]= "Une erreur s'est produite empêchant la destruction de l'enregistrement"
    else
      flash[:notice]= "Enregistrement effacé"
    end
    redirect_to admin_organism_archives_url(@organism)
  end




end
