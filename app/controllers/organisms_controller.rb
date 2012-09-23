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
    
    # Ce min est nécessaire car il y a un problème avec les soldes si la date du jour est postérieure à la date de clôture
    # du dernier exercice - probablement il faut trouver plus élégant
    @date=[@organism.periods.last.close_date, Date.today].min

    # Construction des éléments des paves
    @paves=[]
    @paves += @organism.books.all.reject {|b| b.class.name == 'OdBook'}
    @paves << @period
    @paves += cash_books
    @paves += bank_books



    
    
  end


  protected


  def cash_books
     @organism.cashes.map do |c|
      cb = @organism.virtual_books.new
      cb.virtual = c
      cb
    end
  end

  def bank_books
    @organism.bank_accounts.map do |ba|
      vb = @organism.virtual_books.new
      vb.virtual = ba
      vb
    end
  end

end
