# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# new permet d'afficher la vue qui demande quel fichier importer
# puis create parse les données et affiche la vue confirm
# laquelle contient un bouton de confirmation qui renvoie sur l'action rebuild.
#
# En cas de changement d'architecture, ne pas oublier de modifier la liste
# des modèles dans initializers/constants.rb
# et de redémarrer le serveur après cette modification

class Admin::RestoresController < Admin::ApplicationController
  
  class RestoreError < StandardError; end
   RESTOREMODELS = %w(period bank_account destination line bank_extract check_deposit cash cash_control account nature bank_extract_line income_book outcome_book od_book transfer)


  def new
    
  end

  # create 
  #  - lit le fichier sélectionné avec Psych,
  #  - et crée les données qui seront ensuite utilisées pour la vue de confirmation.
  #  - Crée un fichier temporaire qui sera stocké dans le répertoire tmp
  #  - Et enfin appelle la vue confirm
  # TODO  pour effacer les fichiers temporaires qui s'accumuleraient
  # TODO en utilisation multi user, il faudrait que le fichier porte une identification de son créateur
  def create
    @just_filename = File.basename(params[:file_upload].original_filename).gsub(/[^\w\.\_]/, '_')
    raise RestoreError, "Erreur : l'extension du fichier ne correspond pas.\n" unless (@just_filename =~ /.yml$/)
    read_and_check_datas
    File.open("#{Rails.root}/tmp/#{@just_filename}", 'wb') {|f| f.write(@datas.to_yaml) } #params[:file_upload].read) }
    # raise 'fichier trop petit' if File.size("#{Rails.root}/tmp/#{@just_filename}") < 1500
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
      redirect_to admin_organisms_path
    else
      raise RestoreError, "ComptaRestorer n'a pas pu reconstuire les données"
    end
  rescue  RestoreError => error
    flash[:alert] = "Erreur dans la recontruction des données #{error.message}"
    redirect_to new_admin_restore_path
  ensure
    File.delete(tmp_file_name)
  end

  protected

  # remplit @datas avec les valeurs du fichier uploadé et les contrôle sommairement
  # TODO en fait le seul objectif ici est de checker mais comme cela ne marche guère
  def read_and_check_datas
    # load_models
    @datas = Psych.load(params[:file_upload])
  #  check_datas
  end


  # require models smeble nécessaire pour le parsing, en tout cas en mode développement
  # pour que le parser connaisse les modèles qu'il trouve dans le fichier et
  # sache les restaurer.
  # Require models ne semble pas suffisant donc j'utilise maintenant load_models
  # TODO voir si c'est nécessaire pour un environnement de production
  def require_models
    (['book'] + ::ORGMODELS).each { |model_name| require(model_name + '.rb') }
  end

  def load_models
   load 'organism.rb'
   RESTOREMODELS.each { |model_name| load(model_name + '.rb') }
  end

  # vérifie que tous les modèles sont valides, ce qui ne veut pas dire que
  # la reconstruction des données sera OK car il peut y avoir des incohérences
  # FIXME certaines validations font appel à des records existants, comme
  # line_date, must_belongs_to_period
  # La restauration marche donc tant que l'ancienne compta est présente
  # mais ne marche pas lorsque l'ancienne compta est absente (effacée ou autre PC)
  # check_datas a donc été supprimé de read_and_check_datas
  # et de read_tadas_from_tmp_file
  def check_datas
     raise RestoreError, "Organisme absent" if @datas[:organism].nil?
     raise RestoreError, "Modèle Organism invalide" unless @datas[:organism].valid?
     ::MODELS.each do |m|
       if @datas[m.pluralize.to_sym]
         @datas[m.pluralize.to_sym].each  {|r|  raise(RestoreError, "Enregistrement invalide : Modèle #{m} - id #{r.id if r} - #{r.errors.messages}")   unless r.valid? }
       end
     end
    
  end

  def read_datas_from_tmp_file(tmp_file_name)
   #  load_models
    @datas = Psych.load(File.read(tmp_file_name))
    # check_datas
  end

end