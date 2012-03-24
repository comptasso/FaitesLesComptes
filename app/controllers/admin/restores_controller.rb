# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# new permet d'afficher la vue qui demande quel fichier importer
# puis create parse les données et affiche la vue confirm
# laquelle contien un bouton de confirmation qui renvoie sur l'action rebuild. 
#

#require 'organism'
#require 'period'
#require 'bank_account'
#require 'destination'
#require 'nature'
#require 'cash'
#require 'bank_extract'
#require 'line'
#require 'book'
#require 'income_book'
#require 'outcome_book'
#require 'bank_extract_line'
#require 'check_deposit'
#require 'cash_control'
#require 'account'

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
    a = Archive.new
    a.parse_file(tmp)
    unless a.errors.any?
      @datas=a.datas
      File.open("#{Rails.root}/tmp/#{@just_filename}", 'w') {|f| f.write a.datas.to_yaml}
      render :confirm
    else
      message += a.list_errors
      flash[:alert]=message
      render :new
    end
 
  end
 
  def rebuild
    a= Archive.new
    tmp_file_name="#{Rails.root}/tmp/#{params[:file_name]}"
    a.parse_file(File.open(tmp_file_name,'r') {|f| f.read})
    if  a.rebuild_organism
      flash[:notice]= "Importation de l'organisme #{a.datas[:organism].title} effectuée"
    else
      flash[:alert]= "Une erreur de lecture du fichier n'a pas permis de reconstituer les données"
    end
  ensure
    File.delete(tmp_file_name)
    redirect_to admin_organisms_path
  end


  


end