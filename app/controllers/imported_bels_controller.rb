class ImportedBelsController < ApplicationController
  
  before_filter  :find_bank_account
  
  def index
    @imported_bels = @bank_account.imported_bels.order(:date, :position)
    flash[:notice] = 'Aucune ligne importée en attente' if @imported_bels.empty?
  end
  
  private

  def find_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
  end
end
