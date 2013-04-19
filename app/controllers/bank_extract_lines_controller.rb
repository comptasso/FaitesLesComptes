class BankExtractLinesController < ApplicationController
  
  # TODO on pourrait modifier les routes pour avoir juste bank_extract_bank_extract_line et récupérer les variables d'instances nécessaires
 
  before_filter :find_params

  def index
    @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
  end

  

  # action pour procéder au pointage d'un extrait bancaire
  # récupère l'extrait, les lignes qui lui sont déjà associées et les lignes de ce compte bancaire
  # qui ne sont pas encore associées à un extrait.
  #
  def pointage
    redirect_to bank_extract_bank_extract_lines_url(@bank_extract) if @bank_extract.locked
    # les trois variables d'instance pour la modalbox qui permet d'ajouter une écriture
    @in_out_writing =InOutWriting.new(date:@bank_extract.begin_date)
    @line = @in_out_writing.compta_lines.build
    @counter_line = @in_out_writing.compta_lines.build(account_id:@bank_account.current_account(@period).id)
    # les variables d'instances pour l'affichage de la vue pointage
    @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
    @lines_to_point = @bank_account.not_pointed_lines
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

  # Degroupe permet de scinder une ligne
  #
  # Appelle le même template que rgroup car c'est une logique de traitement similaire
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
    @lines_to_point = @bank_account.not_pointed_lines
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
      l = ComptaLine.find(params[:line_id])
      @bel = @bank_extract.bank_extract_lines.new(:compta_lines=>[l])
      
    respond_to do |format|
      if @bel.save
        @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
        @lines_to_point = @bank_account.not_pointed_lines
        format.js 
      else
        format.js { render 'flash_error'}
      end
    end

  end


  # Insert est appelée par le drag and drop de la vue pointage lorsqu'une
  # non pointed line est transférée dans les bank_extract_line
  #
  # L'id de la ligne non pointée doit être de la forme
  # type_id (ex line_545)
  #
  # params[:at] indique à quelle position insérer la ligne dans la liste
  #
  def insert
    id = params[:html_id][/\d+$/].to_s
    l = ComptaLine.find(id)
    @bel = @bank_extract.bank_extract_lines.new(:compta_lines=>[l])
    @bel.position = params[:at].to_i
    respond_to do |format|
      if @bel.save
        @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
        format.js 
      else
        format.js { render 'flash_error'}
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
    @bank_extract_lines = @bank_extract.bank_extract_lines.order(:position)
    render :format=>:js
  rescue
    head :bad_request
  end

  

  private

  def find_params
    
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    # TODO ? ici il faut changer d'exercice si les dates du bank_extract ne sont pas dans l'exercice
    @bank_account = @bank_extract.bank_account
    @organism = @bank_account.organism
  end
end
