
# Ce controller est utilisé pour gérer les écritures générées par la vue modale
# que l'on trouve dans le pointage des comptes bancaires.
# Il n'y a qu'une action (create) qui est appelée par une fonction ajax.
class ModallinesController < ApplicationController

  def create
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    @bank_account = @bank_extract.bank_account
    complete_params
    @in_out_writing = InOutWriting.new(params[:in_out_writing])
    # nécessaire pour pouvoir refaire le formulaire
    @line = @in_out_writing.compta_lines.first
    @counter_line = @in_out_writing.compta_lines.last
    
    if @in_out_writing.save
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

  # recopie dans la counter_line les attributs nécessaires de la line
  #
  # En même temps, complète l'attribut account_id avec le numéro de compte correspondant
  # à l'exercice.
  def complete_params
    param =  params[:in_out_writing][:compta_lines_attributes]
    param['1'][:account_id] = @bank_account.current_account(@period).id
    param['1'][:credit] = param['0'][:debit] || 0
    param['1'][:debit]= param['0'][:credit] || 0
    
  end

end
