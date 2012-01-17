# -*- encoding : utf-8 -*-

class LinesController < ApplicationController

  

  layout :choose_layout # inutile maintenant car lié à l'utilisation de modalbox

 # pour être sur d'avoir l'organisme avant d'appeler le before filter de 
 # application_controller qui va remplir le period (lequel est utile pour les soldes)
  prepend_before_filter :find_book
  before_filter :fill_mois, only: [:index, :new]

  # GET /lines
  # GET /lines.json
  def index
  
     fill_soldes
     respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lines }
      format.pdf { @listing = Listing.new(@period, @mois, @book) }
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
   if @book.class.to_s == 'IncomeBook'
     @natures=@period.natures.recettes
   else
     @natures=@period.natures.depenses
   end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line }
      
    end
  end


  # POST /lines
  # POST /lines.json
  def create
    flash[:date]= get_date # permet de transmettre la date à l'écriture suivante
    @line = @book.lines.new(params[:line])
    respond_to do |format|
      if @line.save
        mois=(@line.line_date.month)-1
        format.html { redirect_to new_book_line_url(@book,mois: mois), 
          notice: "La ligne #{@line.narration} - Débit : #{two_decimals @line.debit} - Crédit : #{two_decimals @line.credit} a été créée." }
         # redirection via js non utilisé actuellement - sera utile pour faire une modalbox
#        format.js do
#          logger.debug 'dans create if line.save'
#          fill_soldes
#          render :redirect
#        end
        format.json { render json: @line, status: :created, location: @line }
      else
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
       # format.js
      end
    end
  end

  def edit
    @line = @book.lines.find(params[:id])
  end
  
  
  
  # PUT /lines/1
  # PUT /lines/1.json
    def update
      get_date
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
        format.html { redirect_to book_lines_url(@book) }
        format.json { head :ok }
      end
    end

  protected

 
  def find_book
    @book=Book.find(params[:book_id] || params[:income_book_id] || params[:outcome_book_id] )
    @organism=@book.organism
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
     redirect_to book_lines_url(@book, mois: @mois) if (params[:action]=='index')
     redirect_to new_book_line_url(@book,mois: @mois) if params[:action]=='new'
    end
  end

  
  def choose_layout
    (request.xhr?) ? nil : 'application'
  end

  def fill_soldes
    @date=@period.start_date.months_since(@mois.to_i)
   
    @lines = @book.lines.mois(@date).all
    @solde_debit_avant=@book.lines.solde_debit_avant(@date)
    @solde_credit_avant=@book.lines.solde_credit_avant(@date)

    @total_debit=@lines.sum(&:debit)
    @total_credit=@lines.sum(&:credit)
    @solde= @solde_credit_avant+@total_credit-@solde_debit_avant-@total_debit
  end

  def get_date
    params[:line][:line_date]= picker_to_date(params[:pick_date_line])
  end



end
