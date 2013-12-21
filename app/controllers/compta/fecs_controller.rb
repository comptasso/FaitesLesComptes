# coding: utf-8

# Controller permettant d'envoyer au format csv le fichier des écritures comptables
# telles que demandé par le Ministère des Finances 
class Compta::FecsController < Compta::ApplicationController

  def show
    @exfec = Extract::Fec.new(period_id:@period.id)
    respond_to do |format|
        format.csv { send_data @exfec.to_csv, filename:export_filename(@exfec, :csv, "FEC #{@period.short_exercice}") }  # pour éviter le problème des virgules
    end

  end

  
 
end