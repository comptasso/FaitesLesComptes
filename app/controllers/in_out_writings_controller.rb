# -*- encoding : utf-8 -*-

class InOutWritingsController < ApplicationController
 
  before_filter :find_book # remplit @book
  before_filter :fill_mois, only: [:index, :new]
  before_filter :check_if_has_changed_period, only: :index # car on peut changer de period quand on clique sur une
  # des barres du graphe.qui est affiché par organism#show
  before_filter :fill_natures, :only=>[:new,:edit] # pour faire la saisie des natures en fonction du livre concerné

  # GET /in_out_writings
  def index
    if params[:mois] == 'tous'
      @monthly_extract = Utilities::InOutExtract.new(@book, @period)
    else
      @monthly_extract = Utilities::MonthlyInOutExtract.new(@book, year:params[:an], month:params[:mois])
    end
    respond_to do |format|
      format.html  # index.html.erb
      format.pdf {send_data @monthly_extract.to_pdf.render, :filename=>"#{@organism.title}_#{@book.title}.pdf" }
      format.csv { send_data @monthly_extract.to_csv  }  # pour éviter le problème des virgules
      format.xls { send_data @monthly_extract.to_xls  } #{ render :text=> @monthly_extract.to_xls(col_sep:"\t") }  # nécessaire pour excel
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
        Rails.logger.warn("erreur dans create_line")
        Rails.logger.warn(@in_out_writing.errors.messages)
        Rails.logger.warn(@counter_line.inspect)
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


  # complète les informations pour la counter_line en remplissant les
  # champs débit et crédit à partir du champ de la compta_line
  def fill_counter_line
      p  = params[:in_out_writing][:compta_lines_attributes]
      p['1'][:credit] = p['0'][:debit] || 0
      p['1'][:debit]= p['0'][:credit] || 0
      
  end


  # Initie la variable d'instance book
  def find_book
    @book=Book.find(params[:book_id] || params[:income_book_id] || params[:outcome_book_id] )
  end

  # fill_mois construit le MonthYear qui sera utilisé pour bâtir l'extrait mensuel du livre
  # si le paramètre mois est tous, c'est que l'utilisateur veut effectivement la 
  # totalité des lignes, ce fait poursuive normalement vers la fonction index
  #
  # Même si on demande tous les mois, il faut quand même définir un @monthyear car cette variable
  # est utilisée par check_if_has_changed_period pour vérifier qu'on n'a pas changé d'exercice.
  #
  def fill_mois
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
      @monthyear=MonthYear.new(month:@mois, year:@an)

    else
      @monthyear= @period.guess_month
      redirect_to new_book_in_out_writing_url(@book, mois:@monthyear.month, an:@monthyear.year) if params[:action]=='new'
      unless params[:mois] == 'tous'
        redirect_to book_in_out_writings_url(@book, mois:@monthyear.month, an:@monthyear.year, :format=>params[:format]) if (params[:action]=='index')
      end
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


  # check_if_has_changed_period est rendu nécessaire car on peut accéder directement aux lignes d'un exercice
  # à partir du graphe d'accueil et donc via l'action index.
  def check_if_has_changed_period
    # si le month_year demandé ne fait pas partie de l'exercice,
    if !@period.list_months.include?(@monthyear)
      # voit si on peut trouver l'exercice ad hoc
      @new_period = @organism.guess_period(@monthyear.beginning_of_month)
      if @new_period
        flash[:alert]= "Attention, vous avez changé d'exercice !"
        my = @new_period.guess_month(@monthyear.beginning_of_month) # car si les exercices ne sont pas de même durée,
        # on pourrait tomber dans un exercice qui n'existe pas
        session[:period] = @new_period.id
        redirect_to book_in_out_writings_url(@book, mois:my.month, an:my.year, :format=>params[:format])
      else
        flash[:alert] = "Le mois et l'année demandés ne correspondent à aucun exercice"
        redirect_to :back
      end
    end

  end



end
