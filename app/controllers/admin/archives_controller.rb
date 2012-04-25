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
      @tmp_file_name="#{Rails.root}/tmp/#{@archive.title}.yml"
      @archive.collect_datas
      File.open(@tmp_file_name, 'w') {|f| f.write @archive.collect.to_yaml}
      send_file @tmp_file_name, type: 'text/yml'
      File.delete(@tmp_file_name)
    else
      render new
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
