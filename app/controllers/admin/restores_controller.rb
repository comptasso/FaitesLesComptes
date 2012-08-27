# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# new permet d'afficher la vue qui demande quel fichier importer
# puis create charge le fichier et crée la base correspondante

class Admin::RestoresController < Admin::ApplicationController
  
  class RestoreError < StandardError; end

  before_filter :db_format

  def new
    
  end

  # create 
  #  Vérifie que la base de données n'existe pas.
  # Trois cas de figure : soit elle existe et appartient au user
  # soit elle existe et n'appartient pas au user
  # soit elle n'existe pas.
  # Dans tous les cas, on demande une confirmation
  def create

    uploaded_io = params[:file_upload]

    begin
      # vérifier que le nom du fichier est correct /pas de signes spéciaux .sqlite3
      unless params[:database_name] =~ /^[a-z][a-z0-9]*$/
        raise RestoreError, 'Le nom pour la base de données ne doit comporter que des minsucules sans espace'
      end
      # vérification que l'extension est bien la bonne
      extension = File.extname(uploaded_io.original_filename)
      if  ".#{@db_format}" != extension
        raise RestoreError, "L'extension #{extension} du fichier ne correspond pas aux bases gérées par l'application : .#{@db_format}"
      end

      # la base ne doit pas déjà appartenir à un autre
      r = Room.find_by_database_name(params[:database_name]) # le nom de la base existe
      if r != nil && r.user != current_user
        raise RestoreError, 'Ce nom de base est déjà pris et ne vous appartient pas'
      end
      
      # si la base n'existe pas on doit la créer
      if r == nil
        @new_room = current_user.rooms.new(database_name:params[:database_name])
        raise RestoreError, 'Impossible de créer la base pour cet utilisateur' unless @new_room.valid?
      end
      
      # enregistrament du fichier dans son espace 
      File.open(Rails.root.join('db', Rails.env, 'organisms', "#{params[:database_name]}.sqlite3"), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      
      # on change le database_name de l'organisme au cas où ce ne serait pas le même qu'à l'origine
      use_org_connection(params[:database_name])
           
      # TODO il faudrait ici cpaturer les exceptions et effacer les traces.
      # On indique à l'organisme quelle base il utilise (puisqu'on peut faire des copies)
      Organism.first.update_attribute(:database_name, params[:database_name])
      # tout s'est bien passé on sauve la nouvelle pièce
      use_main_connection
      @new_room.save!
      
         
      flash[:notice] = "Le fichier a été chargé et peut servir de base de données"
      redirect_to admin_organisms_url

    rescue RestoreError => e
      flash[:alert] = e.message
      render 'new'
    end
  end


  protected

  # retourne le nom de l'adapter de l'application, par exemple sqlite3.
  def db_format
    @db_format = Rails.application.config.database_configuration[Rails.env]['adapter']
  end
 

end