class BankExtractLinesController < ApplicationController
  
  # TODO on pourrait modifier les routes pour avoir juste bank_extract_line et récupérer les variables d'instances nécessaires
  # En fait il n'y en probablement plus besoin puisque le format html n'est pas nécessaire pour ce controller

  before_filter :find_params

  def up
      
      @bank_line.move_higher
      @bank_lines =@bank_line.bank_extract.bank_extract_lines.order('position') # utile pour js, redessiner la table des bank_extract_lines
       respond_to do |format|
      format.html {redirect_to pointage_organism_bank_account_bank_extract_url(@organism, @bank_account, @bank_extract)}
      format.js {render 'up_down'}
    end
      
      
  end

  def down
        @bank_line.move_lower
        @bank_lines =@bank_line.bank_extract.bank_extract_lines.order('position') # utile pour js, redessiner la table des bank_extract_lines
       respond_to do |format|
      format.html {redirect_to pointage_organism_bank_account_bank_extract_url(@organism, @bank_account, @bank_extract)}
      format.js {render 'up_down'}
    end
      
  end

  private

  def find_params
    @bank_line=BankExtractLine.find(params[:id])
    @organism=Organism.find(params[:organism_id])
    @bank_account=BankAccount.find(params[:bank_account_id])
    @bank_extract=BankExtract.find(params[:bank_extract_id])
  end
end
