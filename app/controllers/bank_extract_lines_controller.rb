class BankExtractLinesController < ApplicationController
  
  before_filter :find_parents

  def up
      @bank_line=BankExtractLine.find(params[:id])
      @bank_line.move_higher
       respond_to do |format|
      format.html {redirect_to pointage_organism_bank_account_bank_extract_url(@organism, @bank_account, @bank_extract)}
      format.js
    end
      
      
  end

  def down
      @bank_line=BankExtractLine.find(params[:id])
      @bank_line.move_lower
      redirect_to pointage_organism_bank_account_bank_extract_url(@organism, @bank_account, @bank_extract) 
  end

  private

  def find_parents
    @organism=Organism.find(params[:organism_id])
    @bank_account=BankAccount.find(params[:bank_account_id])
    @bank_extract=BankExtract.find(params[:bank_extract_id])
  end
end
