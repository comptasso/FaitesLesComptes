# -*- encoding : utf-8 -*-



# Cette classe agit comme un proxy pour accéder aux organismes qui sont dans
# des bases séparées (Room étant par contre dans la base commune).
#
# Ce controller gère ce qui relève de la création des bases de données (ou des schémas).
#
# Ce controller est nécessaire car autrement dans les vues où il y a plusieurs organismes
# ces organismes ont l'id  1 (puisqu'ils sont seuls dans leur base).
# 
# Pour des vues de type index et pour les actions, il faut donc passer par rooms
class Admin::RoomsController < Admin::ApplicationController

  skip_before_filter :find_organism, :current_period
  
  after_filter :clear_org_cache, only:[:create]

  # affiche la liste des bases appartenant au current_user
  def index
    @rooms = current_user.rooms
   
    unless current_user.up_to_date?
      status = current_user.status 
      alert = []
      alert += ["Une base au moins est en retard par rapport à la version de votre programme, migrer la base correspondante"] if status.include? (:late_migration)
      alert += ["Une base au moins est en avance par rapport à la version de votre programme, passer à la version adaptée"] if status.include? (:advance_migration)
      alert += ['Un fichier correspondant à une base n\'a pu être trouvée ; vous devriez effacer l\'enregistrement correspondant'] if status.include? (:no_base)
      flash[:alert] = alert.join("\n")
    end
    
  end
    
  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to admin_organism_path(@organism)
  end

  # Action permettant de mettre à jour la base de données
  def migrate
    @room = current_user.rooms.find(params[:id])
    @room.migrate
    organism_has_changed?(@room)
    flash[:notice] = 'La base a été migrée et mise à jour'
    redirect_to admin_organism_url
  end


  # action qui permet de créer une nouvelle archive lorsque l'on affiche la liste des
  # organismes
  def new_archive
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to new_admin_organism_archive_url(@organism)
  end

  # GET /rooms/new
  def new
    @organism = Organism.new
  end

  # POST /rooms
  def create
   
    @organism = Organism.new(params[:organism])
    @room = current_user.rooms.new(database_name:params[:organism][:database_name])
    # vérifie que le fichier de base de données n'existe pas
    # TODO Faire un un nom de base préfixé pour éviter le risque de doublons trop fréquents
    
    
    if @organism.valid? && @room.valid?

      @room.save # un after_create du modèle créé la nouvelle base de données et s'y connecte
      @organism.save
      session[:org_db]  = @organism.database_name
      redirect_to new_admin_organism_period_url(@organism), notice: "Création de l'organisme effectuée, un livre des recettes et un livre des dépenses ont été créés.\n
          Il vous faut maintenant créer un exercice pour cet organisme"
    else
      copy_room_errors(@room)
      render :new
    end
    
   
  end 


  # détruit la pièce ainsi que la base associée
  #
  def destroy
    @room = current_user.rooms.find(params[:id])
    
    db_name= @room.db_filename
    Rails.logger.info "Destruction de la base #{db_name}  - méthode rooms_controller#destroy}"
  
    if @room.destroy
      # on détruit le fichier correspondant
      # FIXME sur windows au moins, semble poser un problème de droit d'accès
      # donc on n'efface pas le fichier
      notice = "L'organisme suivi par la base #{db_name} a été supprimé;"
      notice += "<br/> Le fichier #{db_name} existe encore.<br/>
         Pour le supprimer faites le manuellement à partir de l'explorateur de fichiers" if ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
      flash[:notice] =  notice.html_safe
      organism_has_changed?
      redirect_to admin_rooms_url
    else
      flash[:alert] = "Une erreur s'est produite; la base #{db_name} n'a pas été supprimée"
      redirect_to admin_organism_url(@room.organism)
    end
  end

  protected

  # copy les messages d'erreur de room vers organism pour
  # que le form puisse avoir les informations nécessaires
  def copy_room_errors(r)
    unless r.valid?
      r.errors.messages.each_pair do |k, mess|
        @organism.errors.add(k, mess.first) # on ne recopie que le premier des messages d'erreur
      end
    end
  end

  end
