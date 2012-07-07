# -*- encoding : utf-8 -*-

class LinesController < ApplicationController

  # TODO verifier 'utilité de ce choose layout
  layout :choose_layout # inutile maintenant car lié à l'utilisation de modalbox

  prepend_before_filter :find_book # remplit @book mais aussi @organism et @period

  skip_before_filter [:find_organism, :current_period]
  # skip_before_filter :current_period # l'organisme et la période sont identifiée par find_book
  # TODO le puts qui est dans current_period laisse penser que current_period est appelé . Comprendre pourquoi

    
  before_filter :change_period, only: [:index] # pour permettre de changer de period quand on clique sur une
  # des barres du graphe.qui est affiché par organism#show
  before_filter :fill_mois, only: [:index, :new]
  before_filter :fill_natures, :only=>[:new,:edit] # pour faire la saisie des natures en fonction du livre concerné

  # GET /lines
  # GET /lines.json 
  def index  
    @date = Date.civil(@an.to_i, @mois.to_i)
    @monthly_extract = Utilities::MonthlyBookExtract.new(@book, @date)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lines }
      format.pdf { @listing = Listing.new(@period, @mois, @book)}
      format.csv
    end
  end


  # appelé par l'icone clé dans l'affichage des lignes pour
  # verrouiller la ligne concernée.
  # la mise à jour de la vue est faite par lock.js.erb qui
  # cache les icones modifier et delete, ainsi que l'icone clé et
  # fait apparaître l'icone verrou fermé.
  #  def lock
  #    @line=Line.find(params[:id])
  #    if @line.update_attribute(:locked, true)
  #      respond_to do |format|
  #        format.js # appelle validate.js.erb
  #      end
  #    end
  #  end

 

  # GET /lines/new
  # GET /lines/new.json
  def new
    @line =@book.lines.new(line_date: flash[:date] || @period.start_date.months_since(@mois.to_i), :cash_id=>@organism.main_cash_id, :bank_account_id=>@organism.main_bank_id)
    @previous_line = Line.find_by_id(flash[:previous_line_id]) if flash[:previous_line_id]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line }
     end
  end


  # POST /lines
  # POST /lines.json
  def create
   
    @line = @book.lines.new(params[:line])
    respond_to do |format|
      if @line.save
        flash[:date]=@line.line_date # permet de transmettre la date à l'écriture suivante
        flash[:previous_line_id]=@line.id
        mois = (@line.line_date.month)-1
        format.html { redirect_to new_book_line_url(@book,mois: mois) }
        format.json { render json: @line, status: :created, location: @line }
      else
        fill_natures
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
        # format.js
      end
    end 
  end

  def edit
    logger.debug LinesController._process_action_callbacks.map(&:filter).join("\n")
    @line = @book.lines.find(params[:id])
  end
  
  
  
  # PUT /lines/1
  # PUT /lines/1.json
  def update
    
    @line = @book.lines.find(params[:id])
  
    respond_to do |format|
      if @line.update_attributes(params[:line])
        mois=(@line.line_date.month) -1
        format.html { redirect_to book_lines_url(@book, mois: mois) }#], notice: 'Line was successfully updated.')}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lines/1
  # DELETE /lines/1.json
  def destroy
    @line = @book.lines.find(params[:id])
    @line.destroy
  
    respond_to do |format|
      format.html { redirect_to book_lines_url(@book, :mois=>@period.guess_month(@line.line_date)) }
      format.json { head :ok }
    end
  end

  protected

 
 
  def find_book
    @book=Book.find(params[:book_id] || params[:income_book_id] || params[:outcome_book_id] )
    @organism=@book.organism
   @period= @organism.periods.find(session[:period])
  end

  def fill_mois
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
    else
      @month= @period.guess_month
      redirect_to book_lines_url(@book, mois:@month[:month], an:@month[:year], :format=>params[:format]) if (params[:action]=='index')
      redirect_to new_book_line_url(@book,mois: @mois) if params[:action]=='new'
    end
  end


  # TODO ici il faut remplacer cette méthode par une méthode period.natures_for_book(@book) qui choisira les natures qui
  # conviennent à la classe du livre.
  # FIXME render new ne repassant pas par les filtres les @natures du formulaire sont toutes les natures
  # et non pas seulement celles relatives au book
  def fill_natures
    if @book.class.to_s == 'IncomeBook'
      @natures=@period.natures.recettes
    else
      @natures=@period.natures.depenses
    end
  end

  
  def choose_layout
    (request.xhr?) ? nil : 'application'
  end
  
  # change period est rendu nécessaire car on peut accéder directement aux lignes d'un exercice
  # à partir du graphe d'accueil. 
  # TODO Il serait peut être plus judicieux de se déconnecter complètement de la notion d'exercice 
  # pour avoir alors un appel avec month et year, ce qui oterait toute ambiguité. 
  def change_period
    if params[:period_id] &&  (params[:period_id].to_i != session[:period])
      @period = @organism.periods.find(params[:period_id])
      session[:period]=@period.id
      flash[:alert]= "Attention, vous avez changé d'exercice !"
      redirect_to book_lines_url(params[:book_id], :mois=>params[:mois])
    else
      @period=@organism.periods.find(session[:period])
    end
  end



end
