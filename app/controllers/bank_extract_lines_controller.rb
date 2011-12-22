class BankExtractLinesController < ApplicationController
  
  before_filter :find_parents

  def up
      @bank_line=BankExtractLine.find(params[:id])
      @bank_line.move_higher
      redirect_to organism_bank_account_bank_extract_url(@organism,@bank_account,@bank_extract)
  end

  def down
      @bank_line=BankExtractLine.find(params[:id])
      @bank_line.move_lower
      redirect_to organism_bank_account_bank_extract_url(@organism,@bank_account,@bank_extract)
  end

  private

  def find_parents
    @organism=Organism.find(params[:organism_id])
    @bank_account=BankAccount.find(params[:bank_account_id])
    @bank_extract=BankExtract.find(params[:bank_extract_id])
  end
end
