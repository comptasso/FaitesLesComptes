# -*- encoding : utf-8 -*-





class TransfersController < ApplicationController 

  before_filter :find_book # find_book renvoie le OdBook
  before_filter :fill_mois, only: [:index, :new]

  # GET /transfers
  # GET /transfers.json
  def index
    @transfers = Transfer.within_period(@period).order('date ASC')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transfers }
    end
  end

  
  # GET /transfers/new
  # GET /transfers/new.json
  def new
    @transfer = @book.transfers.new
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
    params[:transfer][:compta_lines_attributes]['0'][:credit] = params[:transfer][:amount]
    params[:transfer][:compta_lines_attributes]['1'][:debit] = params[:transfer][:amount]
    # effacer le paramètre amount est indispensable car sinon, sur un new, cela aboutit à
    # créer 4 compta_lines : les deux engendrées par les paramètres compta_lines_attributes en plus des
    # deux engendrées par le after_initialize
    params[:transfer].delete(:amount)
    
    @transfer = @book.transfers.new(params[:transfer])

    respond_to do |format|
      if @transfer.save
        format.html { redirect_to transfers_url, notice: "Le transfert a été enregistré sous le numéro d'écriture #{@transfer.id}" }
      else
     #   Rails.logger.debug "ERREUR dans save : nb de lignes : #{@transfer.compta_lines.inspect}"
        format.html { render action: "new" }
      end
    end
  end

  # PUT /transfers/1
  # PUT /transfers/1.json
  def update
    @transfer = Transfer.find(params[:id])

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
    @book = OdBook.first
  end

  def local_params
    {}
  end

end
