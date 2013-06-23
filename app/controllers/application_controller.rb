# -*- encoding : utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery

 # before_filter :control_version

  before_filter :authenticate_user!

 #  before_filter :log_in?

  before_filter :find_organism, :current_period
  
  helper_method :two_decimals, :virgule, :picker_to_date, :current_user, :current_period?, :abc

  private


  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    devise_sessions_bye_path
  end

  # A chaque démarrage de l'application, on vérifie que la base principale
  # (celle qui contient les Room)
  # est cohérente avec la version du logiciel.
  #
  def control_version
    Rails.logger.info 'appel de controle version'
    @control_version = Room.version_update?
  end

   # vérifie que l'on est loggé sous un nom d'utilisateur,
  # s'il n'y a pas de session[:user], et à nil session[:org_db]
  def log_in?
    if session[:user]
      @user = User.find_by_id(session[:user])
    else
      
      logger.debug "pas de session[user]"
      session[:org_db] = nil
      use_main_connection
      redirect_to new_session_url
    end
   

  end

  # fait un reset de la session si on a changé d'organism et sinon
  # trouve la session pour toutes les actions qui ont un organism_id
  def find_organism
    # utile pour remettre le système cohérent
    use_main_connection if session[:org_db] == nil
    r = current_user.rooms.find_by_database_name(session[:org_db]) if session[:org_db]
    if r # on doit avoir tru=ouvé une room
      r.connect_to_organism
      @organism = Organism.first # il n'y a qu'un organisme par base
     
    end
    # si pas d organisme (cas d une base corrompue)
    unless @organism
      session[:org_db] = nil
      use_main_connection
    #  redirect_to admin_rooms_url and return
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
 
  # pour afficher une virgule à la place du point décimal.
  # TODO remplacer tous les recours à two_decimals par virgule chaque fois que possible.
  def two_decimals(montant)
    sprintf('%0.02f',montant)
  rescue
    '0.00'
  end

  # Pour transformer un montant selon le format numérique français avec deux décimales
  def virgule(montant)
    ActionController::Base.helpers.number_with_precision(montant, precision:2) rescue '0,00'
  end

 
  # se connecte à la base principale
  def use_main_connection
    Rails.logger.info "début de use_main_connection : connecté à à #{ActiveRecord::Base.connection_config}"
    Apartment::Database.switch()
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

  # fill_mois est utile pour tous les controller que l'on peut appeler avec une options qui peut être
  #   rien et dans ce cas, fill_mois trouve le mois le plus adapté
  #   mois:'tous' pour avoir tous les mois d'affichés
  #   mois:2, an:2013 pour demander un mois spécifique
  #
  # local_params doit renvoyer un hash avec les paramètres complémentaires nécessaires
  # essentiellement un id d'un objet, par exemple :cash_id=>@cash}
  #
  #
  # Ceci permet alors d'avoir un routage vers cash_cash_lines_path(@cash) en supposant
  # que l'on soit dans le controller cash_lines et avec l'action index 
  #
  def fill_mois
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
      @monthyear = @period.guess_month_from_params(month:@mois, year:@an)
    else
      @monthyear= @period.guess_month
      redirect_to url_for(mois:@monthyear.month, an:@monthyear.year) if params[:action]=='new'
      unless params[:mois] == 'tous'
        redirect_to url_for(mois:@monthyear.month, an:@monthyear.year, :format=>params[:format]) if (params[:action]=='index')
      end
    end
  end

  # raccourci pour avoir la configuration
  def abc
    ActiveRecord::Base.connection_config
  end
  
  

  

end
