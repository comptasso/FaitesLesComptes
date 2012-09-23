
# Ce controller est utilisé pour gérer les écritures générées par la vue modale
# que l'on trouve dans le pointage des comptes bancaires

class ModallinesController < ApplicationController

  def create
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    @bank_account = @bank_extract.bank_account
    @organism = @bank_account.organism


    params[:line][:counter_account_id] = @bank_account.current_account(@period).id
    @line = Line.new(params[:line])
    if @line.save
      
      @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
      respond_to do |format|
        format.js
      end

    else
     
      respond_to do |format|
        format.js {render :new }
      end
      
    end




  end

end
