# -*- encoding : utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :control_version

  before_filter :log_in?

  before_filter :find_organism, :current_period
  
  helper_method :two_decimals, :picker_to_date, :current_user, :current_user?, :current_period?

  private

  # A chaque démarrage de l'application, on vérifie que les bases de données
  # sont cohérentes avec la version du logiciel.
  #
  def control_version
    Rails.logger.info 'appel de controle version'
    @control_version ||= Rails.cache.fetch('version_update') do
      Rails.logger.info 'appel du cache version_update?'
      Room.version_update?
    end
    redirect_to admin_versions_new_path unless @control_version
  end

 

  # fait un reset de la session si on a changé d'organism et sinon
  # trouve la session pour toutes les actions qui ont un organism_id
  def find_organism
    # utile pour remettre le système cohérent
    use_main_connection if session[:org_db] == nil
    if session[:org_db]
      r = current_user.rooms.find_by_database_name(session[:org_db])
      r.connect_to_organism
      @organism = Organism.first # il n'y a qu'un organisme par base
    end
  end

  # si pas de session, on prend le premier exercice non clos
  def current_period 
    unless @organism
      logger.warn 'Appel de current_period sans @organism'
      return nil
    end
    if session[:period]
      @period = @organism.periods.find_by_id(session[:period]) rescue nil
    else
      return nil if @organism.periods.empty?
      @period = @organism.periods.last
      session[:period] = @period.id
    end
    @period
  end

  def current_period?(p)
    p == current_period
  end

  # HELPER_METHODS
 
  def two_decimals(montant)
    sprintf('%0.02f',montant)
  rescue
    '0.00'
  end

  # picker_to_date est utilisée pour transformer le retour du widget
  # date picker qui est sous la forme "dd/mm/aaaa".Alors que Date.civil
  # demande aaaa,mm,dd.
  # On utilise donc split puis reverse puis to_i (et l'opérateur splat : * ) pour
  # transmettre ces arguments
  # La fonctin retourne un objet Date ou nil si la string ne permet pas de former
  # une date valide
  #

  # TODO à supprimer en intégrant ces fonctions dans le modèle
  # déja fait pour line, en cours pour cash_control
  # voir à les supprimer également dans les parties admin et compta
  def picker_to_date(string)
    s = string.split('/')
    Date.civil(*s.reverse.map{|e| e.to_i})
  rescue
    @period.guess_date
  end

  # vérifie que l'on est loggé sous un nom d'utilisateur,
  # s'il n'y a pas de session[:user], et à nil session[:org_db]
  def log_in?

    unless session[:user]
      logger.debug "pas de session[user]"
      session[:org_db] = nil
      use_main_connection
      redirect_to new_session_url
    end

    
  end

  def current_user
    @user = User.find_by_id(session[:user]) if session[:user]
  end

  def current_user?
    session[:user]
  end

  # se connecte à la base principale
  def use_main_connection
    Rails.logger.info "début de use_main_connection : connecté à à #{ActiveRecord::Base.connection_config}"
    ActiveRecord::Base.establish_connection Rails.env.to_sym
    Rails.logger.info "appel de use_main connection : connexion à #{ActiveRecord::Base.connection_config}"
  end
  
  # Méthode à appeler dans les controller rooms pour
  # mettre à jour la session lorsqu'il y a un changement d'organisme
  # Récupère également les variables d'instance @organism et @period si cela a du sens.
  #
  def organism_has_changed?(groom = nil)
    change = false
    # premier cas : il y a une chambre et on vient de changer
    if groom && session[:org_db] != groom.database_name
      logger.info "Passage à l'organisation #{groom.database_name}"
      session[:period] = nil
      session[:org_db]  = groom.database_name
      groom.connect_to_organism
      @organism  = Organism.first
      if @organism && @organism.periods.any?
        @period = @organism.periods.last
        session[:period] = @period.id
      end
      change =true
    end
    
    # deuxième cas : il n'y a pas ou plus de chambre
    if groom == nil #: on vient d'arriver ou de supprimer un organisme
      logger.info "Aucune chambre sélectionné"
      use_main_connection
      session[:period] = nil
      session[:org_db] = nil
      change = true
    end

    # troisème cas : on reste dans la même pièce
    if groom && session[:org_db] == groom.database_name
      logger.info "On reste à l'organisation #{groom.database_name}"
      @organism = Organism.first
      logger.warn 'pas d\'organisme trouvé par has_changed_organism?' unless @organism
      current_period
      change = false
    end
    change
  end

  
  
  

  

end
