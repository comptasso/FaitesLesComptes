# Construit un nouveau Journal Général et l'affiche

class Compta::GeneralLedgersController < Compta::ApplicationController
  
  def new
    @general_ledger =  Compta::PdfGeneralLedger.new(@period)
    cookies[:general_ledger_token] = { :value =>params[:token], :expires => Time.now + 1800 }
    respond_to do |format|
        format.pdf  {send_data @general_ledger.render,
          filename:"Journal_General_#{@organism.title}.pdf"} 
    end
  end
  
end
