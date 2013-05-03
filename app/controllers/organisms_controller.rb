# -*- encoding : utf-8 -*-

class OrganismsController < ApplicationController

  
 
  # GET /organisms/1 test watcher
  # GET /organisms/1.json
  def show
    @current_user = current_user
    
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer au moins un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
   
    @date = @period.guess_date

    # Construction des éléments des paves
    @paves = []
    @paves += @organism.books.in_outs.all
    @paves << @period
    @paves += @organism.cash_books
    @paves += @organism.bank_books
 
  end


  
  
end
