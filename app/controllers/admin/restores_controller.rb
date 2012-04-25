# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# new permet d'afficher la vue qui demande quel fichier importer
# puis create parse les données et affiche la vue confirm
# laquelle contient un bouton de confirmation qui renvoie sur l'action rebuild.
#

class Admin::RestoresController < Admin::ApplicationController
 MODELS = %w(organism period bank_account destination line bank_extract check_deposit cash cash_control book account nature bank_extract_line income_book outcome_book od_book transfer)


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
    load_models
    @datas = YAML.load(params[:file_upload].tempfile)
    unless @error_parsing
      File.open("#{Rails.root}/tmp/#{@just_filename}", 'w') {|f| f.write @datas.to_yaml}
      render :confirm
    else
      flash[:alert] = @error_parsing
      render :new
    end
 
  end
 
  def rebuild
    tmp_file_name="#{Rails.root}/tmp/#{params[:file_name]}"
    File.open(tmp_file_name,'r') do |f|
      @datas = YAML.load(f)
    end
    a = Restore::RestoredCompta.new(@datas)
    if  a.rebuild_all_records
      flash[:notice]= "Importation de l'organisme #{a.datas[:organism].title} effectuée"
    else
      flash[:alert]= "Une erreur de lecture du fichier n'a pas permis de reconstituer les données"
    end
  ensure
    File.delete(tmp_file_name)
    redirect_to admin_organisms_path
  end

  protected

  def load_models
     MODELS.each { |model_name| load(model_name + '.rb') }
  end

      # parse_file prend un fichier archive, charge les fichiers nécessaires
    # load et non require pour être certain de les recharger si nécessaire
    # et retourne les @datas
    def parse_file(file_name)
      load_models
      ds = {}
      File.open(file_name, 'r') do |f|
        ds = YAML.load(f)
      end
     ds
    rescue  Psych::SyntaxError
      @error_parsing = "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
    end




  


end