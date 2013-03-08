# -*- encoding : utf-8 -*-

class OrganismsController < ApplicationController

  

  def index 
    @room_organisms = current_user.rooms.collect do |r|
      {:organism=>r.organism, :room=>r, :archive=>(r.look_for {Archive.last}) }
    end
  end
 
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
    @paves += cash_books
    @paves += bank_books
 
  end


  protected

  
# crée un virtual_book pour chacune des caisses
  def cash_books
     @organism.cashes.map do |c|
      cb = @organism.virtual_books.new
      cb.virtual = c
      cb
    end
  end

  # créé un virtual_book pour chacun des comptes bancaires
  def bank_books
    @organism.bank_accounts.map do |ba|
      vb = @organism.virtual_books.new
      vb.virtual = ba
      vb
    end
  end

end
