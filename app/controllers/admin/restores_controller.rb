# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# 
#

class Admin::RestoresController < Admin::ApplicationController

  def new
    
  end

  def create
     @just_filename = File.basename(params[:file_upload].original_filename)
    message=''
    message += "Erreur : l'extension du fichier ne correspond pas.\n" unless (@just_filename =~ /.yml$/)
    if message != ''
      flash[:alert]=message
      render :new
      return
    end
    # ici on récupère le fichier 
    tmp = params[:file_upload].tempfile
    a=Admin::Archive.new
    a.parse_file(tmp)
    if a.valid?
       @datas=a.datas
      File.open("#{Rails.root}/tmp/#{@just_filename}", 'w') {|f| f.write a.datas.to_yaml}
 
       render :confirm
    else
      message += a.list_errors
      flash[:alert]=message
      render :new
    end
 
  end



  def archive
    @organism=Organism.find(params[:id])
    tmp_file_name="#{Rails.root}/tmp/#{@organism.title}.yml"
    # Créer un fichier : y écrirer les infos de l'exercice
    a=Admin::Archive.new
    a.collect_datas(@organism)
    File.open(tmp_file_name, 'w') {|f| f.write a.datas.to_yaml}
    send_file tmp_file_name, type: 'text/yml'
    File.delete(tmp_file_name)
  end

  def rebuild
    a= Admin::Archive.new
    tmp_file_name="#{Rails.root}/tmp/#{params[:file_name]}"
    y=''
    File.open(tmp_file_name,'r') {|f| y =f.read}
   
    a.parse_file(y)
    @datas=a.datas
    if a.valid?
 #     render text: @datas.to_s
      a.rebuild_organism

    else
      flash[:alert]= "Une erreur de lecture du fichier n'a pas permis de reconstituer les données"
      
    end
    redirect_to admin_organisms_path

  end


  


end