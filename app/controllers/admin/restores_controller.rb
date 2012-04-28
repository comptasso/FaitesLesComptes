# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# new permet d'afficher la vue qui demande quel fichier importer
# puis create parse les données et affiche la vue confirm
# laquelle contient un bouton de confirmation qui renvoie sur l'action rebuild.
#

class Admin::RestoresController < Admin::ApplicationController
  MODELS = %w(organism period bank_account destination line bank_extract check_deposit cash cash_control book account nature bank_extract_line income_book outcome_book od_book transfer)

  class RestoreError < StandardError; end
  

  def new
    
  end

  # create 
  #  - lit le fichier sélectionné avec YAML, 
  #  - et crée les données qui seront ensuite utilisées pour la vue de confirmation.
  #  - Crée un fichier temporaire qui sera stocké dans le répertoire tmp
  #  - Et enfin appelle la vue confirm
  # TODO voir comment on efface les fichiers temporaires qui s'accumuleraient
  # TODO en utilisation multi user, il faudrait que le fichier porte une identification de son créateur
  def create
    @just_filename = File.basename(params[:file_upload].original_filename)
    raise RestoreError, "Erreur : l'extension du fichier ne correspond pas.\n" unless (@just_filename =~ /.yml$/)
    require_models
    @datas = YAML.load(params[:file_upload].tempfile)
    File.open("#{Rails.root}/tmp/#{@just_filename}", 'w') {|f| f.write @datas.to_yaml}
    render :confirm
  rescue  Psych::SyntaxError,  RestoreError => error
    alert =case error
    when RestoreError then  error.message
    when Psych::SyntaxError
      if error.message =~ /YAML at/
        line_with_error = error.message[/line (\d*)/,1]
        column_with_error = error.message[/column (\d*)/,1]
        "Lecture des données impossible. Erreur à la ligne #{line_with_error}, colonne #{column_with_error}"
      else
        "Une erreur s'est produite lors de la lecture du fichier"
      end
    end
      flash[:alert] = alert
      render :new
    end
 
    def rebuild
      tmp_file_name = "#{Rails.root}/tmp/#{params[:file_name]}"
      read_datas_from_tmp_file(tmp_file_name)
      a = Restore::ComptaRestorer.new(@datas)
      if  a.compta_restore
        flash[:notice]= "Importation de l'organisme #{a.datas[:organism].title} effectuée"
      else
        flash[:alert]= "Une erreur de lecture du fichier n'a pas permis de reconstituer les données"
      end
    ensure
      File.delete(tmp_file_name)
      redirect_to admin_organisms_path
    end

    protected


    # require models smeble nécessaire pour le parsing, en tout cas en mode développement
    # pour que le parser connaisse les modèles qu'il trouve dans le fichier et
    # sache les restaurer
    # TODO voir si c'est nécessaire pour un environnement de production
    def require_models
      MODELS.each { |model_name| require(model_name + '.rb') }
    end

    def read_datas_from_tmp_file(tmp_file_name)
      File.open(tmp_file_name,'r')  { |f| @datas = YAML.load(f) }
    end

 end