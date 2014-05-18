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
        if @bels_importer.need_extract?(@period)
          redirect_to new_bank_account_bank_extract_path(@bank_account),
            notice: 'Les écritures importées nécessitent la création d\'un extrait de compte'
        else
          redirect_to bank_account_imported_bels_path(@bank_account), 
            notice: "Importation du relevé effectuée"
        end
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