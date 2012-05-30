# -*- encoding : utf-8 -*-

class TransfersController < ApplicationController
  # GET /transfers
  # GET /transfers.json
  def index
    @transfers = @organism.transfers.order('date ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transfers }
    end
  end

  # GET /transfers/1
  # GET /transfers/1.json
  def show
    @transfer = Transfer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transfer }
    end
  end

  # GET /transfers/new
  # GET /transfers/new.json
  def new
    @transfer = Transfer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transfer }
    end
  end

  # GET /transfers/1/edit
  def edit
    @transfer = Transfer.find(params[:id])
  end

  # POST /transfers
  # POST /transfers.json
  def create
    @transfer = @organism.transfers.new(params[:transfer])

    respond_to do |format|
      if @transfer.save
        format.html { redirect_to organism_transfers_url(@organism), notice: 'Le transfert a été enregistré' }
       
      else
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
        format.html { redirect_to organism_transfers_url(@organism), notice: 'Transfert mis à jour' }
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
      format.html { redirect_to organism_transfers_url(@organism) }
      format.json { head :no_content }
    end
  end
end
