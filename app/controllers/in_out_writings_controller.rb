# -*- encoding : utf-8 -*-

class InOutWritingsController < ApplicationController

  before_filter :find_book # remplit @book
  before_filter :fill_mois, only: [:index, :new]
  before_filter :check_if_has_changed_period, only: :index # car on peut changer de period quand on clique sur une
  # des barres du graphe.qui est affiché par organism#show
  before_filter :fill_natures, :only=>[:new,:edit] # pour faire la saisie des natures en fonction du livre concerné

  # GET /in_out_writings
  def index
    @monthly_extract = Utilities::MonthlyInOutExtract.new(@book, year:params[:an], month:params[:mois])
    respond_to do |format|
      format.html  # index.html.erb
      format.json { render json: @lines }
      format.pdf
      format.csv { send_data @monthly_extract.to_csv(col_sep:"\t")  }  # pour éviter le problème des virgules
      format.xls { send_data @monthly_extract.to_xls(col_sep:"\t")  } #{ render :text=> @monthly_extract.to_xls(col_sep:"\t") }  # nécessaire pour excel
    end
  end

  # GET /in_out_writings/new
  def new
    @in_out_writing =@book.in_out_writings.new(date: flash[:date] || @monthyear.beginning_of_month)
    @line = @in_out_writing.compta_lines.build
    @counter_line = @in_out_writing.compta_lines.build
    if flash[:previous_line_id]
      @previous_line = ComptaLine.find_by_id(flash[:previous_line_id])
      @line.payment_mode = @previous_line.payment_mode
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line }
    end
  end


  # POST /lines
  # POST /lines.json
  def create
    fill_counter_line
    @in_out_writing = @book.in_out_writings.build(params[:in_out_writing])
    @line = @in_out_writing.in_out_line
    @counter_line=@in_out_writing.counter_line
    respond_to do |format|
      if @in_out_writing.save
        flash[:date]=@in_out_writing.date # permet de transmettre la date à l'écriture suivante
        flash[:previous_line_id]=@line.id
        mois = sprintf('%.02d',@in_out_writing.date.month); an = @in_out_writing.date.year
        format.html { redirect_to new_book_in_out_writing_url(@book, mois:mois, an:an) }

      else
        fill_natures
        format.html { render action: "new" }

      end
    end
  end

  def edit
    @in_out_writing = @book.in_out_writings.find(params[:id])
    @line = @in_out_writing.in_out_line
    @counter_line = @in_out_writing.counter_line
  end



  # PUT /lines/1
  # PUT /lines/1.json
  def update
    @in_out_writing = @book.in_out_writings.find(params[:id])
    @line = @in_out_writing.in_out_line
    @counter_line = @in_out_writing.counter_line
    fill_counter_line
    respond_to do |format|
      if @in_out_writing.update_attributes(params[:in_out_writing])
        mois = sprintf('%.02d',@in_out_writing.date.month); an =  @in_out_writing.date.year
        format.html { redirect_to book_in_out_writings_url(@book, mois:mois, an:an) }#], notice: 'Line was successfully updated.')}
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
    @w = @book.in_out_writings.find(params[:id])
    my = MonthYear.from_date(@w.date)
    @w.destroy

    respond_to do |format|
      format.html { redirect_to book_in_out_writings_url(@book, :mois=>my.month, :an=>my.year) }
      format.json { head :ok }
    end
  end

  protected

  def fill_counter_line
      p  = params[:in_out_writing][:compta_lines_attributes]
      p['1'][:credit] = p['0'][:debit] || 0
      p['1'][:debit]= p['0'][:credit] || 0
      p['1'][:payment_mode] = p['0'][:payment_mode]
  end


  def find_book
    @book=Book.find(params[:book_id] || params[:income_book_id] || params[:outcome_book_id] )
  end

  def fill_mois
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
      @monthyear=MonthYear.new(month:@mois, year:@an)

    else
      @monthyear= @period.guess_month
      redirect_to book_in_out_writings_url(@book, mois:@monthyear.month, an:@monthyear.year, :format=>params[:format]) if (params[:action]=='index')
      redirect_to new_book_in_out_writing_url(@book, mois:@monthyear.month, an:@monthyear.year) if params[:action]=='new'
    end
  end


  # TODO ici il faut remplacer cette méthode par une méthode period.natures_for_book(@book) qui choisira les natures qui
  # conviennent à la classe du livre.
  def fill_natures
    if @book.class.to_s == 'IncomeBook'
      @natures=@period.natures.recettes
    elsif @book.class.to_s == 'OutcomeBook'
      @natures=@period.natures.depenses
    end
  end


  # change period est rendu nécessaire car on peut accéder directement aux lignes d'un exercice
  # à partir du graphe d'accueil et donc via l'action index.
  def check_if_has_changed_period
    # si le month_year demandé ne fait pas partie de l'exercice,
    if !@period.list_months.include?(@monthyear)
      # voit si on peut trouver l'exercice ad hoc
      @new_period = @organism.find_period(@monthyear.beginning_of_month)
      if @new_period
        flash[:alert]= "Attention, vous avez changé d'exercice !"
        session[:period] = @new_period.id
        redirect_to book_in_out_writings_url(@book, mois:@monthyear.month, an:@monthyear.year, :format=>params[:format]) if (params[:action]=='index')
      else
        flash[:alert] = "Le mois et l'année demandés ne correspondent à aucun exercice"
        redirect_to :back
      end
    end

  end



end