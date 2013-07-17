# -*- encoding : utf-8 -*-

class Compta::WritingsController < Compta::ApplicationController

  before_filter :find_book
  before_filter :prefill_date, :only=>:new

  # GET /writings
  # GET /writings.json
  def index
    # pas de sélection par mois pour la AnBook
    if @book.type == 'AnBook'
       params[:mois] = 'tous'
       params[:an] = nil
    end
    if params[:mois]
      find_writings
    else
       my = MonthYear.from_date(@period.guess_month)
       redirect_to compta_book_writings_url(@book, mois:my.month, an:my.year) and return
    end
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @writings }
    end
  end


   
  # GET /writings/new
  # GET /writings/new.json
  def new
    flash[:alert] = 'Peut-être devriez vous plutôt écrire sur ce livre dans la partie saisie' if @book.type.in? ['IncomeBook', 'OutcomeBook']
    @writing = @book.writings.new(date: @d)
    if flash[:previous_writing_id]
      @previous_writing = Writing.find_by_id(flash[:previous_writing_id])
    end
    2.times {@writing.compta_lines.build}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @writing }
    end
  end

  # GET /writings/1/edit
  def edit
    @writing = Writing.find(params[:id])
  end

  # POST lock
  # action qui verrouille l'écriture
  # TODO transformer cette action en remote pour éviter de reconstruire toute la vue
  # l'utilisation des paramètres permet de revenir au mois affiché (ou à la vue tous)
  def lock
    @mois = params[:mois]
    @an = params[:an]
    @writing = Writing.find(params[:id])
    @writing.lock
    redirect_to compta_book_writings_url(@book, :mois=>@mois, an:@an)
  end

  # POST all_lock
  # action qui verrouille la totalité des écritures qui peuvent être verrouillées
  def all_lock
    find_writings
    @writings.unlocked.each {|w| w.lock if w.compta_editable?}
    redirect_to compta_book_writings_url(@book)
  end

  # POST /writings
  # POST /writings.json
  def create
    params[:writing][:date_picker] ||=  l(@period.start_date)
    @writing = @book.writings.new(params[:writing])

    respond_to do |format|
      if @writing.save
        flash[:date]=@writing.date # permet de transmettre la date à l'écriture suivante
        flash[:previous_writing_id]=@writing.id
        format.html {
          if @book.type == 'AnBook'
            redirect_to compta_book_writings_url(@book)
          else
            redirect_to new_compta_book_writing_url(@book)
          end
           }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /writings/1
  # PUT /writings/1.json
  def update
    @writing = Writing.find(params[:id])

    respond_to do |format|
      if @writing.update_attributes(params[:writing])
         my = MonthYear.from_date(@writing.date)
         format.html { redirect_to compta_book_writings_url(@book, mois:my.month, an:my.year), notice: 'Ecriture mise à jour.' }
     else
        format.html { render action: "edit" }
     end
    end
  end

  # DELETE /writings/1
  # DELETE /writings/1.json
  def destroy
    @writing = Writing.find(params[:id])
    @writing.destroy

    respond_to do |format|
      my = MonthYear.from_date(@writing.date)
      format.html { redirect_to compta_book_writings_url(@book, mois:my.month, an:my.year), notice: "Ecriture n° #{@writing.id} effacée" }
    end
  end

  protected

  def find_book
    @book = Book.find(params[:book_id])
  end

  def find_writings
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
      date = Date.civil(@an.to_i, @mois.to_i, 1) rescue @period.guess_month
      @writings = @book.writings.mois(date)
    else
      @mois = 'tous'
      @writings = @book.writings.period(@period)
    end
  end

  # préremplit la date
  def prefill_date
    @d = flash[:date] # en priorité la date venant de l'écriture précédente
    @d = @period.start_date if @book.type == 'AnBook' # mais toujours le début de l'éxercice si livre d'A Nouveau
    @d ||= @period.guess_date # sinon par défaut, on devine
  end


end
