# -*- encoding : utf-8 -*-

class CheckDepositsController < ApplicationController

  before_filter :find_bank_account_and_organism
  before_filter :get_pick_date, only: [:create,:update]

  # GET /check_deposits
  # GET /check_deposits.json
  def index
    @lines=@organism.lines.non_depose
    @total_lines_credit=@lines.sum(:credit)
    flash[:notice]="Il y a #{@lines.count} chèques à remettre à l'encaissement pour un montant de #{sprintf('%0.02f', @lines.sum(:credit))} €"
    @check_deposits = @organism.check_deposits.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @check_deposits }
    end
  end

  # GET /check_deposits/1
  # GET /check_deposits/1.json
  def show
    @check_deposit = CheckDeposit.find(params[:id])
     respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @check_deposit }
    end
  end

  # GET /check_deposits/new
  # GET /check_deposits/new.json
  
  def new
    @lines=@organism.lines.non_depose
    @total_lines_credit=@lines.sum(:credit)
    if @lines.count == 0
      redirect_to  bank_account_check_deposits_url(@bank_account), alert: "Il n'y a pas de chèques à remettre"
      return
    end
    @check_deposit = @bank_account.check_deposits.new(deposit_date: Date.today)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @check_deposit }
    end
  end


  # GET /check_deposits/1/fill
  # fill permet de choisir les chèques que l'on va associer à la remise de chèque
  def fill
    @check_deposit = CheckDeposit.find(params[:id])
    @lines=@organism.lines.non_depose
    @total_lines_credit=@lines.sum(:credit)
  end

  def add_check
    @line=Line.find(params[:line_id])
    @check_deposit=CheckDeposit.find(params[:id])
    @line.update_attributes(:check_deposit_id=>@check_deposit.id, :bank_account_id=>@check_deposit.bank_account.id)
    @lines=@organism.lines.non_depose
    @total_lines_credit=@lines.sum(:credit)
    respond_to do |format|
      format.html # new.html.erb
      format.js {render 'toggle_check'}
      end
    
  end

  def remove_check
    @line=Line.find(params[:line_id])
    @check_deposit=CheckDeposit.find(params[:id])
    @check_deposit.remove_check(@line)
    @lines=@organism.lines.non_depose
    @total_lines_credit=@lines.sum(:credit)
    respond_to do |format|
      format.html # new.html.erb
      format.js {render 'toggle_check'}
    end
  end

  # GET /check_deposits/1/edit
  def edit
    @check_deposit = CheckDeposit.find(params[:id])
    @lines=@organism.lines.non_depose
    @total_lines_credit=@lines.sum(:credit)
  end

  # POST /check_deposits
  # POST /check_deposits.json
  def create
    @check_deposit = @bank_account.check_deposits.new(params[:check_deposit])

    respond_to do |format|
      if @check_deposit.save
        format.html {
          flash[:notice]= 'La remise de chèques a été créée.'
           if params[:commit] == 'Tout remettre'
           @organism.lines.non_depose.all.each do |l|
             l.update_attributes(:check_deposit_id=>@check_deposit.id, :bank_account_id=>@check_deposit.bank_account.id)
             l.save
           end
           redirect_to bank_account_check_deposit_url(@bank_account, @check_deposit)
           else
          redirect_to fill_bank_account_check_deposit_url(@bank_account, @check_deposit)
           end
          }
        format.json { render json: @check_deposit, status: :created, location: @check_deposit }
      else
        format.html { render action: "new" }
        format.json { render json: @check_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /check_deposits/1
  # PUT /check_deposits/1.json
  def update
    @check_deposit = CheckDeposit.find(params[:id])

    respond_to do |format|
      if @check_deposit.update_attributes(params[:check_deposit])
        format.html { redirect_to  [@bank_account, @check_deposit], notice: 'La remise de chèque a été modifiée.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @check_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_deposits/1
  # DELETE /check_deposits/1.json
  def destroy
    @check_deposit = CheckDeposit.find(params[:id])
    @check_deposit.destroy

    respond_to do |format|
      format.html { redirect_to bank_account_check_deposits_url(@bank_accounts) }
      format.json { head :ok }
    end
  end

  private

  def find_bank_account_and_organism
    @bank_account=BankAccount.find(params[:bank_account_id])
    @organism=@bank_account.organism
  end

  def get_pick_date
    params[:check_deposit][:deposit_date]= picker_to_date(params[:pick_date])
  end
end
