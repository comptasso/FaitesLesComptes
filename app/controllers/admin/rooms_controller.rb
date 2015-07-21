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

  before_filter :owner_only, only:[:destroy]

  after_filter :clear_org_cache, only:[:create, :destroy]

  # affiche la liste des bases appartenant au current_user
  # le status permet de gérer les éventuels différences de migration si on
  # importe une base (même si en pratique on ne le fait jamais).
  def index
    # TODO probablement améliorable en utilisant la méthode
    # User#organisms_with_romm
    lm = Room.jcl_last_migration
    @rooms = current_user.rooms.includes(:holders).references(:holders)
    @status = @rooms.collect {|r| r.relative_version(lm)}
    build_flash_from_status(@status)
  end

  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to admin_organism_path(@organism)
  end

  # TODO supprimer cette logique et la route
  # Action permettant de mettre à jour la base de données
  def migrate
    @room = current_user.rooms.find(params[:id])
    # FIXME crée une erreur car migrate n'existe plus
    @room.migrate
    organism_has_changed?(@room)
    flash[:notice] = 'La base a été migrée et mise à jour'
    redirect_to admin_organism_url
  end



  # GET /rooms/new
  def new
    logger.debug 'Passage par le controller admin_room'
    use_main_connection
    @room = Room.new
  end

  # POST /rooms
  def create
    @room = Room.new(room_params)

    if build_a_new_room # ce qui indique que tout s'est bien passé
      @organism = @room.organism
      session[:org_db]  = @organism.database_name
      redirect_to new_admin_organism_period_url(@organism), notice: flash_creation_livres
    else
      flash.now[:alert] = 'Il n\'a pas été possible d\'enregistrer la structure'
      render :new
    end


  end


  # détruit la pièce ainsi que la base associée.
  #
  # Le before_filter only_owner instancie @room
  #
  def destroy

    db_name= @room.database_name
    Rails.logger.info "Destruction de la base #{db_name}  - méthode rooms_controller#destroy}"

    if @room.destroy
      flash[:notice] =  "L'organisme suivi par la base #{db_name} a été supprimé".html_safe
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
  #  def copy_room_errors(r)
  #    unless r.valid?
  #      r.errors.messages.each_pair do |k, mess|
  #        @organism.errors.add(k, mess.first) # on ne recopie que le premier des messages d'erreur
  #      end
  #    end
  #  end

  def build_flash_from_status(status)
    return if status.uniq == [:same_migration]
    alert = []
    alert += ["Une base au moins est en retard par rapport à la version de votre programme, migrer la base correspondante"] if status.include? (:late_migration)
    alert += ["Une base au moins est en avance par rapport à la version de votre programme, passer à la version adaptée"] if status.include? (:advance_migration)
    alert += ['Un fichier correspondant à une base n\'a pu être trouvée ; vous devriez effacer l\'enregistrement correspondant'] if status.include? (:no_base)
    flash.now[:alert] = alert.join("\n")
  end

  #TODO faire spec de cette méthode
  def build_a_new_room
    @room.errors.add(:base, 'Nombre maximal atteint') unless current_user.allowed_to_create_room?
    unless @room.valid?
      Rails.logger.warn(@room.errors.messages)
      return false
    end
    # TODO à déplacer dans le modèle ROOM
    h = current_user.holders.new(status:'owner')
    result  = User.transaction do
      @room.save
      h.room_id = @room.id
      h.save
      Apartment::Database.switch(@room.database_name)
    end

    result
  end


  def flash_creation_livres
    html = 'Création de l\'organisme effectuée<br />'
    if @organism.status == 'Comité d\'entreprise'
      html += 'Un livre des recettes et un livre des dépenses ont été créés
pour le budget de fonctionnement; de même pour le budget des activités socio_culturelles<br />'
    else
      html += 'Un livre des recettes et un livre des dépenses ont été créés<br />'
    end
    html += 'Il vous faut maintenant créer un exercice pour cet organisme'
    html.html_safe
  end

  # l action destroy ne sont permises que si le current_user est le owner
  def owner_only
    @room = current_user.rooms.find(params[:id])
    unless current_user == @room.owner
      flash[:alert] = "Vous ne pouvez executer cette action car vous n'êtes pas le propriétaire de la base"
      redirect_to admin_rooms_url
    end
  end

  private

  def room_params
    params.require(:room).permit(:database_name, :racine,
      :title, :comment, :status, :postcode, :siren)
  end

end
