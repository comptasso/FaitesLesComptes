
# Ce controller est utilisé pour gérer les écritures générées par la vue modale
# que l'on trouve dans le pointage des comptes bancaires

class ModallinesController < ApplicationController

  def create
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    @bank_account = @bank_extract.bank_account
    complete_params
    @writing = Writing.new(params[:in_out_writing])
    if @writing.save
     
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

  protected

  def complete_params
    param =  params[:in_out_writing][:compta_lines_attributes]
    param['1'][:account_id] = @bank_account.current_account(@period).id
    param['1'][:credit] = param['0'][:debit] || 0
    param['1'][:debit]= param['0'][:credit] || 0
    param['1'][:payment_mode] = param['0'][:payment_mode]
  end

end
