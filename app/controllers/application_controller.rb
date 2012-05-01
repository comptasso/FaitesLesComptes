class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_organism, :current_period

  helper_method :two_decimals, :picker_to_date

  private

  def find_organism
    if params[:organism_id] && (params[:organism_id] != session[:organism].to_s)
      Rails.logger.info "Changement d'organisme : ancien id = #{session[:organism]} nouvel_id #{params[:organism_id]}" 
      reset_session
      session[:organism]=params[:organism_id]
    end
      @organism = Organism.find(session[:organism]) if session[:organism]
  end

  def current_period
    # si on a changé d'organisme, il faut effacer la session[:period]
    if @organism
      pid = session[:period] ||= (@organism.periods.order(:start_date).last.id if @organism.periods.any?)
      @period= Period.find(pid) if pid
    end
     Rails.logger.info "Dans find_period avec session[:period] = #{session[:period]}"
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

  

  

end
