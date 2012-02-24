# -*- encoding : utf-8 -*-

class OrganismsController < ApplicationController
  # GET /organisms
  # GET /organisms.json
  def index
    @organisms = Organism.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisms }
    end
  end

  # GET /organisms/1 test watcher
  # GET /organisms/1.json
  def show
    @organism = Organism.find(params[:id])
    
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer au moins un exercice pour cet organisme'
      redirect_to new_organism_period_url(@organism)
      return
    end
    # on trouve l'exercice à partir de la session mais si on a changé d'organisme
    # il faut changer la session et on charge le dernier exercice par défaut
    begin
      @period = @organism.periods.find(session[:period])
    rescue
      @period = @organism.periods.last
      session[:period]=@period.id
    end
    @bank_accounts=@organism.bank_accounts.all
    @cashes=@organism.cashes.all
    @books=@organism.books.all
       

    # TODO faire une méthode graphic qui évite d'avoir à construire le graphique par défaut
#    @books.each {|b| b.default_graphic}
   
    
    # Ce min est un hack car il y a un problème avec les soldes si la date du jour est postérieure à la date de clôture
    # du dernier exercice - probablement il faut trouver plus élégant
    @date=[@organism.periods.last.close_date, Date.today].min

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @organism }
    end
  end

 
#
#  def stats
#    @date_from = params[:pick_date_from] ? picker_to_date(params[:pick_date_from]) : Date.today.beginning_of_year
#    @date_to = params[:pick_date_to] ? picker_to_date(params[:pick_date_to]) : Date.today.end_of_year
#    @organism=Organism.find(params[:id])
#    @demand=params[:by] # soit nature soit destination
#    @lines = @organism.lines.includes(params[:by]).select("#{@demand}_id, sum(debit) as debit, sum(credit) as credit").group("#{@demand}_id")
#    @total_debit=0
#    @total_credit=0
#
#  end




end
