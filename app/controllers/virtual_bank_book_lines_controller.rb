class VirtualBankBookLinesController < ApplicationController
  before_filter :fill_mois
  
  def index
    @bank_account=BankAccount.find(params[:bank_account_id])
    @virtual_book = @bank_account.virtual_book
    if params[:mois] == 'tous'
      @monthly_extract = Extract::InOut.new(@virtual_book, @period)
    else
      @monthly_extract = Extract::MonthlyInOut.new(@virtual_book, year:params[:an], month:params[:mois])
    end
  end

  
  protected
  # on surcharge fill_mois pour gérer le params[:mois] 'tous'
  def fill_mois
    if params[:mois] == 'tous'
      @mois = 'tous'
    else
      super
    end
  end
end
