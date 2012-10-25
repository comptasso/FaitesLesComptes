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
    
   
    @date=guess_date

    # Construction des éléments des paves
    @paves=[]
    @paves += @organism.books.all.select {|b| b.class.name == 'OdBook'}
    @paves << @period
    @paves += cash_books
    @paves += bank_books



    
    
  end


  protected

  # trouve la meilleure date pour l'affichage du dashboard
  # soit le date du jour s'il y a un exercice correspondant (via la méthode find_period)
  # soit la date la plus proche à partir des exercices passés ou futurs
  def guess_date
    return Date.today if @organism.find_period
    # l'exercice est-il futur
    direction  =  @organism.periods.first.close_date.past?
    direction ? @organism.periods.last.close_date : @organism.periods.first.start_date
  end


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
