class BankExtractLinesController < ApplicationController
  
  # TODO on pourrait modifier les routes pour avoir juste bank_extract_line et récupérer les variables d'instances nécessaires
  # En fait il n'y en probablement plus besoin puisque le format html n'est pas nécessaire pour ce controller

  before_filter :find_params, :except=>:reorder

  def index
    @bank_extract_lines = @bank_extract.bank_extract_lines.order('position')
  end

  # action pour procéder au pointage d'un extrait bancaire
  # récupère l'extrait, les lignes qui lui sont déjà associées et les lignes de ce compte bancaire
  # qui ne sont pas encore associées à un extrait
  def pointage
    redirect_to organism_bank_account_bank_extract_url(@organism,@bank_account,@bank_extract) if @bank_extract.locked
    @bank_extract_lines=@bank_extract.bank_extract_lines.order(:position)
    @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
  end


  # appelée par le drag and drop de la vue pointage
  # les paramètres transmis sont
  # -id - id de la ligne qui vient d'être retirée
  # -fromPosition qui indique la position initiale de la ligne
  def remove
    @bank_extract_line = BankExtractLine.find(params[:id])
    @bank_extract_line.remove_from_list
    @bank_extract_line.destroy
    @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
    respond_to do |format|
      format.js
    end
  end


  # insert est appelée par le drag and drop de la vue pointage lorsqu'une
  # non pointed line est transférée dans les bank_extract_line
  def insert
    html_id = params[:html_id]
    html = html_id.split(/_\d+$/).first
    id = html_id[/\d+$/].to_s
    @bel = nil
    case html
    when 'check_deposit'
      @bel =  @bank_extract.check_deposit_bank_extract_lines.new(check_deposit_id:id)
    when 'standard_line'
      l=Line.find(id)
      @bel = @bank_extract.standard_bank_extract_lines.new(bank_extract_id:@bank_extract.id, lines:[l])
    end


    raise "@bel non valide #{html} @bank_extract_id = #{@bank_extract.id}" unless @bel.valid?
    @bel.insert_at(params[:at].to_i)
   
    respond_to do |format|
      if @bel.save
        @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
        format.js 
      else
        format.json { render json: @bel.errors, status: :unprocessable_entity }
      end
    end
  end



  # reorder est appelé par le drag and drop de la vue . Les paramètres
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
