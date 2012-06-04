class BankExtractLinesController < ApplicationController
  
  # TODO on pourrait modifier les routes pour avoir juste bank_extract_bank_extract_line et récupérer les variables d'instances nécessaires
 
  before_filter :find_params, :except=>:reorder

  def index
    @bank_extract_lines = @bank_extract.bank_extract_lines.order('position')
  end

  

  # action pour procéder au pointage d'un extrait bancaire
  # récupère l'extrait, les lignes qui lui sont déjà associées et les lignes de ce compte bancaire
  # qui ne sont pas encore associées à un extrait
  def pointage
    @line = Line.new(:bank_account_id=>@bank_account.id)
    redirect_to bank_extract_bank_extract_lines_url(@bank_extract) if @bank_extract.locked
    @bank_extract_lines=@bank_extract.bank_extract_lines.order(:position)
    @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
  end


  # Regroup permet de regrouper deux lignes
  #
  def regroup
    @bank_extract_line = BankExtractLine.find(params[:id])
    follower = @bank_extract_line.lower_item
    @bank_extract_line.regroup(follower)
    @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
    respond_to do |format|
      format.js
    end
  end

  # Regroup permet de regrouper deux lignes
  #
  def degroup
    @bank_extract_line = BankExtractLine.find(params[:id])
    @bank_extract_line.degroup
    @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
    respond_to do |format|
      format.js {render 'regroup' }
    end
  end


  # appelée par le drag and drop de la vue pointage
  # les paramètres transmis sont
  # -id - id de la ligne qui vient d'être retirée
  # -fromPosition qui indique la position initiale de la ligne
  def remove
    @bank_extract_line = BankExtractLine.find(params[:id])
    @bank_extract_line.destroy
    @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
    @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
    respond_to do |format|
      format.js 
    end
  end

  # ajoute une ligne de droite (non pointée) au tableau de gauche (en le mettant
  # donc à la fin)
  #
  # Les paramètres sont nature (check_deposit ou standard_line
  # et line_id (l'id de la ligne)
  #
  def ajoute
    id = params[:line_id]
    case params[:nature]
    when 'check_deposit'
       @bel =  @bank_extract.check_deposit_bank_extract_lines.new
      # il faut utiliser add_check_deposit pour que @bel ait les infos
      # associées ramplies - voir le modèle
      @bel.add_check_deposit(CheckDeposit.find(id))
    when 'standard_line'
      l=Line.find(id)
      @bel = @bank_extract.standard_bank_extract_lines.new(lines:[l])
    end

     raise "Methode ajoute : @bel non valide @bank_extract_id = #{@bank_extract.id}" unless @bel.valid?

    # on redessine les tables

    @lines_to_point = Utilities::NotPointedLines.new(@bank_account)

    respond_to do |format|
      if @bel.save
        @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
        @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
        format.js 
      else
        format.json { render json: @bel.errors, status: :unprocessable_entity }
      end
    end

  end


  # Insert est appelée par le drag and drop de la vue pointage lorsqu'une
  # non pointed line est transférée dans les bank_extract_line
  #
  # L'id de la ligne non pointée doit être de la forme
  # type_id (ex standard_line_766 ou check_deposit_545
  #
  # params[:at] indique à quelle position insérer la ligne dans la liste
  #
  def insert
    html_id = params[:html_id]
    html = html_id.split(/_\d+$/).first
    id = html_id[/\d+$/].to_s
    @bel = nil
    case html
    when 'check_deposit'
      @bel =  @bank_extract.check_deposit_bank_extract_lines.new
      # il faut utiliser add_check_deposit pour que @bel ait les infos
      # associées ramplies - voir le modèle
      @bel.add_check_deposit(CheckDeposit.find(id))
    when 'standard_line'
      l=Line.find(id)
      @bel = @bank_extract.standard_bank_extract_lines.new(lines:[l])
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
  #
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
    
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    @bank_account = @bank_extract.bank_account
    @organism = @bank_account.organism
  end
end
