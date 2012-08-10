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
    if session[:connection_config]
      ActiveRecord::Base.establish_connection(session[:connection_config])
      @organism = Organism.first # il n'y a qu'un organisme par base
    end
  end

  def current_period
    @period = Period.find_by_id(session[:period]) if session[:period]
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
    redirect_to new_session_url unless session[:user]
  end

  def current_user
    cc = ActiveRecord::Base.connection_config
    use_main_connection
    user = User.find(session[:user]) if session[:user]
    ActiveRecord::Base.establish_connection(cc)
    user
  end

  def current_user?
    session[:user]
  end

  def use_main_connection
    # FIXME utiliser une fonction de Rails plutôt que le database construit
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "db/development.sqlite3")
  end

  def use_org_connection(db_name)
     ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "db/organisms/#{db_name}.sqlite3")
  end

  
  
  

  

end
