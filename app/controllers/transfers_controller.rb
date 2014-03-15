# -*- encoding : utf-8 -*-


# le before_filter :find_book renvoie le OdBook de cette compta
# 
# le before_filter :fill_mois qui est défini dans ApplicationController
# a pour objet de remplir les paramètres mois et an et de mettre à disposition
# la variable d'instance @monthyear qui peut alors être utilisée pour 
# initialiser les valeurs dans les vues
#
#
class TransfersController < ApplicationController 

  before_filter :find_book # find_book renvoie le OdBook
  before_filter :fill_mois, only: [:index, :new]

  # GET /transfers
  # GET /transfers.json
  def index
    @transfers = @book.transfers.within_period(@period).order('date ASC') if params[:mois]=='tous'
    @transfers = @book.transfers.mois(@monthyear.beginning_of_month).order('date ASC') if params[:mois] && params[:an]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transfers }
    end
  end
  
  def show
    @transfer = Transfer.find(params[:id])
  end

  
  # GET /transfers/new
  # GET /transfers/new.json
  def new
    @transfer = @book.transfers.new(date:@monthyear.guess_date)
    @transfer.add_lines # crée les deux lignes dont on a besoin pour le formulaire

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transfer }
    end
  end

  # GET /transfers/1/edit
  def edit
    @transfer = Transfer.find(params[:id])
    @line_from = @transfer.line_from
    @line_to = @transfer.line_to
  end

  # POST /transfers
  # POST /transfers.json
  def create
    params_pre_treatment
    @transfer = @book.transfers.new(params[:transfer])
    fill_author(@transfer)
    respond_to do |format|
      if @transfer.save
        my = MonthYear.from_date(@transfer.date)
        format.html { redirect_to transfers_url(my.to_french_h), notice: "Le transfert a été enregistré sous le numéro d'écriture #{@transfer.id}" }
      else
     #   Rails.logger.debug "ERREUR dans save : nb de lignes : #{@transfer.compta_lines.inspect}"
        format.html { render action: "new" }
      end
    end
  end

  # PUT /transfers/1
  # PUT /transfers/1.json
  def update
    params_pre_treatment
    @transfer = Transfer.find(params[:id])
    fill_author(@transfer)
    respond_to do |format|
      if @transfer.update_attributes(params[:transfer])
        format.html { redirect_to transfers_url, notice: 'Transfert mis à jour' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        
      end
    end
  end

  # DELETE /transfers/1
  # DELETE /transfers/1.json
  def destroy
    @transfer = Transfer.find(params[:id]) 
    @transfer.destroy

    respond_to do |format|
      format.html { redirect_to transfers_url }
      format.json { head :no_content }
    end
  end


  protected

  def find_book
    @book = @organism.od_books.first
  end
  
  def params_pre_treatment
    params[:transfer][:compta_lines_attributes]['0'][:credit] = params[:transfer][:amount]
    params[:transfer][:compta_lines_attributes]['1'][:debit] = params[:transfer][:amount]
    # effacer le paramètre amount est indispensable car sinon, sur un new, cela aboutit à
    # créer 4 compta_lines : les deux engendrées par les paramètres compta_lines_attributes en plus des
    # deux engendrées par le after_initialize
    params[:transfer].delete(:amount)
  end

  
end
