# -*- encoding : utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :log_in?

  before_filter :find_organism, :current_period
  #, :current_period

  helper_method :two_decimals, :picker_to_date, :current_user, :current_user?

  private

  # fait un reset de la session si on a changé d'organism et sinon
  # trouve la session pour toutes les actions qui ont un organism_id
  def find_organism
    # utile pour remettre le système cohérent
    use_main_connection if session[:org_db] == nil
    if session[:org_db]
      ActiveRecord::Base.use_org_connection(session[:org_db])
      @organism = Organism.first # il n'y a qu'un organisme par base
    end
  end

  # TODO rajouter si pas de session, on prend le premier exercice non clos
  def current_period
    if @organism
      @period = Period.find_by_id(session[:period]) if session[:period]
    end
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

  def log_in?
    unless session[:user]
      use_main_connection
      redirect_to new_session_url
    end
  end

  def current_user
    User.find_by_id(session[:user]) if session[:user]
  end

  def current_user?
    session[:user]
  end

  # se connecte à la base principale
  def use_main_connection
    # ces méthodes ont été ajoutées par jcl et sont définies dans jcl_monkey_patch.rb
    ActiveRecord::Base.use_main_connection
  end

  # se connect à la base spécifiée par db_name.
  # Ex db_name = 'perso', se connect à la base correspondant au fichier
  # db/organisms/perso.sqlite3
  def use_org_connection(db_name)
    # ces méthodes ont été ajoutées par jcl et sont définies dans jcl_monkey_patch.rb
     ActiveRecord::Base.use_org_connection(db_name)
  end

  
  
  

  

end
