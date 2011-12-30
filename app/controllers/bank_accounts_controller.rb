# -*- encoding : utf-8 -*-

class BankAccountsController < ApplicationController

  before_filter :find_organism, :current_period

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

  
end
