class BankExtractLinesController < ApplicationController
  
  # TODO on pourrait modifier les routes pour avoir juste bank_extract_line et récupérer les variables d'instances nécessaires
  # En fait il n'y en probablement plus besoin puisque le format html n'est pas nécessaire pour ce controller

  before_filter :find_params, :except=>:reorder

  def index
    @bank_extract_lines = @bank_extract.bank_extract_lines.order('position')
  end

  def pointage
    @bank_extract_lines = @bank_extract.bank_extract_lines.order('position')
  end

  # reorder est appelé par le drag and drop de la vue (plugin row-reordering). Les paramètres
  # transmis sont les suivants :
  #  - id :- id of the row that is moved. This information is set in the id attribute of the TR element.
  #  - fromPosition : initial position of the row that is moved. This was value in the indexing cell of the row that is moved.
  #  - toPosition : new position where row is dropped. This value will be placed in the indexing column of the row.
  def reorder
    @bank_extract_line = BankExtractLine.find(params[:id])
    from_position = params[:fromPosition].to_i
    to_position = params[:toPosition].to_i
    if from_position > to_position
      # on remonte vers le haut de la liste
      (from_position - to_position).times { @bank_extract_line.move_higher }
    else
      (to_position - from_position).times { @bank_extract_line.move_lower }
    end
    head :ok
  rescue
    head :bad_request
  end

  

  private

  def find_params
    
    @organism=Organism.find(params[:organism_id])
    @bank_account=BankAccount.find(params[:bank_account_id])
    @bank_extract=BankExtract.find(params[:bank_extract_id])
  end
end
