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
    if @bank_extract.locked
      flash[:notice] = 'Extrait verrouillé, redirection vers la liste des lignes restant à pointer'
      redirect_to lines_to_point_bank_account_bank_extracts_url(@bank_account) 
    end
      @previous_line = ComptaLine.find_by_id(flash[:previous_line_id]) if flash[:previous_line_id]
    prepare_modal_box_instances
    # les variables d'instances pour l'affichage de la vue pointage
    @bank_extract_lines = @bank_extract.bank_extract_lines.includes(:compta_line=>:writing).order(:position)
    @lines_to_point = @bank_account.not_pointed_lines
  end
  
 
  # action qui sera appelée par ajax pour enregistrer les nouvelles positions et les
  # lignes qui sont dans la partie bank_extract_lines de la vue pointage
  #
  # Le javascript envoir les params sous la forme suivante :
  #  Parameters: {"lines"=>{"0"=>"17"}, {"1", "20"}}, "bank_extract_id"=>"7"}
  # 
  #  ou le premier chiffre est la position et le second l'id de la ligne 
  #  
  #  Le bouton Enregistrer qui est dans la vue (avec un button_tag) se voit associer
  #  un appel ajax avec du javascript (voir le fichier pointage.js.coffee).
  #  
  #  La vue appelée ne fait qu'ajouter une notice (les partial flash_error ou 
  #  _flash_success. Une autre partie de l'action est traitée dans le javascript 
  #  qui réaffiche les icones qui sont utilisées dans la vue pointage.
  #
  def enregistrer
    # on efface toutes les bank_extract_lines de cet extrait avant de les reconstruire 
    @bank_extract.bank_extract_lines.each {|bel| bel.destroy}
    @ok = true
    if params[:lines]
      params[:lines].each do |key, clparam|
        cl = @period.compta_lines.find_by_id(clparam)
        if cl
          bel = @bank_extract.bank_extract_lines.new(:compta_line_id=>cl.id)
          bel.position = key
          @ok = false unless bel.save
        end
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
    # @organism = @bank_account.organism
  end
  
  # La vue pointage comprend une boite modale pour ajouter des écritures sans 
  # revenir à la vue de saisie. Cette boîte a besoin de variable d'instances
  # pour que le formulaire soit opérationnel quand il s'affiche.
  def prepare_modal_box_instances
    @in_out_writing =InOutWriting.new(date:@bank_extract.begin_date)
    @line = @in_out_writing.compta_lines.build
    @counter_line = @in_out_writing.compta_lines.build(account_id:@bank_account.current_account(@period).id)
  end
end
