# coding: utf-8

# Voir la classe restore pour les différentes opérations de restauration d'un fichier
#
#

class Admin::ArchivesController < Admin::ApplicationController
  def index
    @archives=@organism.archives.all 
  end

  def show
    @archive=@organism.archives.find(params[:id])
  end

  def new
    @archive=@organism.archives.new
  end 

  def create
    @organism=Organism.find(params[:organism_id])
    @archive=@organism.archives.new(params[:archive])
     
     if @archive.save
      @tmp_file_name="#{Rails.root}/tmp/#{@archive.title}.yml"
      @archive.collect_datas
      File.open(@tmp_file_name, 'w') {|f| f.write @archive.datas.to_yaml}
      send_file @tmp_file_name, type: 'text/yml'
      File.delete(@tmp_file_name)
      # redirect_to admin_organism_archives_url(@organism)
      return
    else
      render new
    end
  end




end
