# -*- encoding : utf-8 -*-

class BelsImportersController < ApplicationController

  before_filter  :find_bank_account
  
  def new
    @bels_import = Utilities::Importer::BelsImporter.new
  end

  def create
    @bels_import = Utilities::Importer::BelsImporter.new(params[:bels_import])
    if @bels_import.save
      redirect_to  notice: "Imported products successfully."
    else
      render :new
    end
  end
  
  private

  def find_bank_account
    @bank_account=BankAccount.find(params[:bank_account_id])
  end
end