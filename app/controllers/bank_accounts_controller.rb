# -*- encoding : utf-8 -*-

class BankAccountsController < ApplicationController

  

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = @organism.bank_accounts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_accounts }
    end
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
    @bank_account = BankAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bank_account }
    end
  end
  
  
  def new_line
    @bank_account = BankAccount.find(params[:id])
    @line = Line.new(bank_account_id:@bank_account.id)
  end



  def add_line
    @bank_account = BankAccount.find(params[:id])
    params[:line][:bank_account_id] = @bank_account.id
    @line = Line.new(params[:line])
  end

  
end
