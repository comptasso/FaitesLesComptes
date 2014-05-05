class ImportedBelsController < ApplicationController
  
  before_filter  :find_bank_account
  before_filter :writable_range_date, only: [:index]
  
   
  def index
    @imported_bels = @bank_account.imported_bels.order(:date, :position)
    flash[:notice] = 'Aucune ligne importée en attente' if @imported_bels.empty?
  end
  
  def update
    @imported_bel = ImportedBel.find params[:id]

    respond_to do |format|
      if @imported_bel.update_attributes(params[:imported_bel])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@imported_bel) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@imported_bel) }
      end
    end
  
  end
  
  # action ayant pour but d'écrire une ligne en comptabilité ainsi que la
  # bank_extract_line qui lui correspond
  def write
    @imported_bel = ImportedBel.find params[:id]
    # récupérer les paramètres
    par = @imported_bel.to_write
    # créer soit le transfert soit le in_out_writing
    if @imported_bel == 'T'
      book = @organism.od_books.first
      @writing = book.transfer.new(par)
    else
      book = @imported_bel.depense? ? 
        @bank_account.sector.outcome_book : bank_account.sector.income_book
      @writing = book.in_out_writings.new(par)
    end
    # rajouter les informations de user (id et ip)
    fill_author(@writing)
    # tenter de le sauver 
    respond_to do |format|
      if @writing.save
        # on détruit l'ibel
        @imported_bel.update_attribute(:writing_id, @writing.id)
        # on renvoie le numéro de la ligne par un message
        format.js {}
      else
        # on envoie un message d'erreur
        format.js {} 
      end
    end 
    
  end
  
  def destroy
    ibel = ImportedBel.find_by_id(params[:id])
    @ibelid = params[:id] # on mémorise l'id pour pouvoir effacer en javascript
    @destruction = ibel.destroy if ibel
    
        
    respond_to do |format|
      format.html { redirect_to bank_account_imported_bels_url(@bank_account) }
      format.js 
    end
    
    
  end  
   
  private

  def find_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
  end
  
  # Cherche les extraits bancaires qui sont ouverts à partir de @period et 
  # @bank_account puis crée un range de date qui sera utilisé dans la vue pour 
  # identifier les ibels qui peuvent être importées de celles qui ne le peuvent pas.
  # 
  # TODO j'ai subi une erreur avec une importation de relevé alors que j'étais dans l'exercice 
  # 2015. Il me proposait quand même de faire le relevé de compte de février 2014.
  # Voir quand on se connecte à être dans un exercice raisonnable. 
  def writable_range_date
    ar = @bank_account.bank_extracts.period(@period).unlocked
    if ar 
      @correct_range_date = ar.first.begin_date..ar.last.end_date
    else
      flash[:error] = 'Pas de relevé de comptes non verrouillé pour cet exercice'
      redirect to bank_account_bank_extracts_path(@bank_account)
    end
  end
  
end
