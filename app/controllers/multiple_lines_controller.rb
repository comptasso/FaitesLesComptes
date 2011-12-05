# -*- encoding : utf-8 -*-
class MultipleLinesController < ApplicationController

  before_filter :find_book
  before_filter :fill_mois, only: [:index, :new]


  # GET /multiple_lines
  def index
    # fait une liste de toutes les lignes multiples
    mlines=@book.lines.where('multiple=?',true).group(:copied_id).all
    @t=[]
    mlines.each { |ml| @t << ml.multiple_info }
  end

  
  ## GET /multiple_line/1/show
  # le paramètre transmis n'est pas l'id de la ligne mais le copied_id
  # permettant, par le scope mutiple, de récupérer toutes les lignes
  # correspondantes
  def show
    # récupérer toutes les lignes relevant de cette écriture mutliple
    @mlines=@book.lines.multiple(params[:id])
    @total_debit=@mlines.sum(:debit)
    @total_credit=@mlines.sum(:credit)
  end

  def new
    @mline=@book.lines.new(line_date: Date.today.beginning_of_year.months_since(@mois.to_i))
  end

  

  def create
    @mline = @book.lines.new(params[:line])

    respond_to do |format|
      if @mline.save
         if params[:repete][:nombre].to_i > 0 # ici on crée les autres lignes...
            nb = @mline.repete(params[:repete][:nombre].to_i,params[:repete][:periode])
         end
       
        format.html { redirect_to book_multiple_lines_path(@book), notice: "#{nb} lignes ont été créées." }
        format.json { render json: @line, status: :created, location: @line }
      else
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # EDIT ne peut changer que les éléments communs. On ne peut changer 
  # le nombre de répétitions, ni la période
  def edit
  # le paramètre transmis n'est pas l'id de la ligne mais le copied_id
  # permettant, par le scope mutiple, de récupérer toutes les lignes
  # correspondantes
    @mline=@book.lines.multiple(params[:id]).first
  end

  def update
    # on récupère le tableau des lignes
   @mlines = @book.lines.multiple(params[:id])
    respond_to do |format|
      # on fait la mise à jour de chacune
      if @mlines.each { |l| l.update_attributes(params[:line]) }

        format.html { redirect_to book_multiple_line_path(@book, params[:id]) , notice: 'La ligne multiple a été mise à jour.'}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /multiple_lines/1
  # DELETE /multiple_lines/1.json
  def destroy
    @mlines = @book.lines.multiple(params[:id])
    @mlines.each {|l| l.destroy}
    respond_to do |format|
      format.html { redirect_to book_multiple_lines_url(@book) }
      format.json { head :ok }
    end
  end

#  def edit
#  end

   private
  def find_book
    @book=book.find(params[:book_id])
    @organism=@book.organism
  end

  def fill_mois
    @mois = params[:mois] || (Date.today.month - 1)
  end

end
