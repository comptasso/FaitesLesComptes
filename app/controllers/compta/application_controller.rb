# -*- encoding : utf-8 -*-

class Compta::ApplicationController < ActionController::Base
  layout 'compta/layouts/application'

  before_filter :current_period_and_organism, :check_natures

  protect_from_forgery

  helper_method :picker_to_date
  
  private

  def find_organism
    @organism=Organism.find(params[:organism_id]) if params[:organism_id]
  end

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

  def current_period_and_organism
    pid = session[:period] ||= (@organism.periods.last.id if  (@organism && @organism.periods.any?))
    @period= Period.find(pid) if pid
    @organism=@period.organism unless @period.nil?
  end

  # vérifie que toutes les natures sont associées à un compte de l'exercice,
  # renvoie false ou true selon que le controle est correct
  def check_natures
    if (@period)
      unless !@period.all_natures_linked_to_account?
        flash[:alert]='Des natures ne sont pas reliées à des comptes'
        
      end
    end
  end
 
end
