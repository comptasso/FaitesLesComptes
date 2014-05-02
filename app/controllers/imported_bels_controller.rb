class ImportedBelsController < ApplicationController
  
  before_filter  :find_bank_account
  before_filter :writable_range_date, except: [:destroy]
  
  
  # TODO il faut identifier le groupe des ibel qui peuvent être sauvés 
  # et les autres
  #
  def index
    @imported_bels = @bank_account.imported_bels.order(:date, :position)
    flash[:notice] = 'Aucune ligne importée en attente' if @imported_bels.empty?
  end
  
  def update
  @imported_bel = ImportedBel.find params[:id]

  respond_to do |format|
    if @imported_bel.update_attributes(params[:imported_bel])
      format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
      format.json { respond_with_bip(@imported_bel) }
    else
      format.html { render :action => "edit" }
      format.json { respond_with_bip(@imported_bel) }
    end
  end
  
  end
  
  def destroy
    ibel = ImportedBel.find_by_id(params[:id])
    @ibelid = params[:id] # on mémorise l'id pour pouvoir effacer en javascript
    @destruction = ibel.destroy if ibel
    
        
    respond_to do |format|
      format.html { redirect_to bank_account_imported_bels_url(@bank_account) }
      format.js 
    end
    
    
  end  
    
    

  
  private

  def find_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
  end
  
  # Cherche les extraits bancaires qui sont ouverts à partir de @period et 
  # @bank_account puis crée un range de date
  def writable_range_date
    ar = @bank_account.bank_extracts.period(@period).unlocked
    @correct_range_date = ar.first.begin_date..ar.last.end_date
  end
  
end
