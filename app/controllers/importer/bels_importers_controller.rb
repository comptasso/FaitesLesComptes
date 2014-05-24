# -*- encoding : utf-8 -*-

module Importer

  class BelsImportersController < ApplicationController

    before_filter  :find_bank_account
  
    def new
      @bels_importer = Importer::Loader.new
    end

    def create
      @bels_importer = Importer::Loader.
        new(params[:importer_loader].
        merge({bank_account_id:@bank_account.id}))
      if @bels_importer.save
        redirect_to bank_account_imported_bels_path(@bank_account), 
            notice: "Importation du relevé effectuée"
      else
         render :new
      end
    end
  
    private

    def find_bank_account
      @bank_account=BankAccount.find(params[:bank_account_id])
    end
    
    
  end

end