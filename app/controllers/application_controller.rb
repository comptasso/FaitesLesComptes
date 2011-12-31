class ApplicationController < ActionController::Base
  protect_from_forgery

    before_filter :find_organism, :current_period

  private

  def find_organism
    @organism=Organism.find(params[:organism_id]) if params[:organism_id]
  end

  helper_method :picker_to_date

   # picker_to_date est utilisée pour transformer le retour du widget
# date picker qui est sous la forme "dd/mm/aaaa".Alors que Date.civil
# demande aaaa,mm,dd.
# On utilise donc split puis reverse puis to_i (et l'opérateur splat : * ) pour
# transmettre ces arguments
# La fonctin retourne un objet Date ou nil si la string ne permet pas de former
# une date valide
#
  def picker_to_date(string)
    return string unless string.is_a?(String)
    return nil if string.empty?
    s=string.split('/')
    return nil unless s.size==3
    begin
    return Date.civil(*s.reverse.map{|e| e.to_i})
    rescue
      nil
    end
  end

   def current_period
   pid = session[:period] ||= (@organism.periods.last.id if @organism)
   @period= Period.find(pid) if pid
 end

end
