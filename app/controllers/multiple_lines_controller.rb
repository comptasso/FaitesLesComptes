# -*- encoding : utf-8 -*-
class MultipleLinesController < ApplicationController

  before_filter :find_listing
  before_filter :fill_mois, only: [:index, :new]


  # GET /multiple_lines
  def index
    # fait une liste de toutes les lignes multiples
    mlines=@listing.lines.where('multiple=?',true).group(:copied_id).all
    @t=[]
    mlines.each { |ml| @t << ml.multiple_info }



  end

  
  ## GET /multiple_line/1/edit
  def show
    # récupérer la ligne
    @mline=@listing.lines.find(params[:id])
    # vérifier qu'on est bien sur une multiple et sinon renvoyer sur le controller line
    redirect_to listing_line_path(@listing, @mline) unless @mline.multiple
    # récupérer toutes les lignes relevant de cette écriture mutliple
    @mlines=@listing.lines.multiple(@mline.copied_id)
    @total_debit=@mlines.sum(:debit)
    @total_credit=@mlines.sum(:credit)
  end

  def new
    @mline=@listing.lines.new(line_date: Date.today.beginning_of_year.months_since(@mois.to_i))
  end

  def create
@mline = @listing.lines.new(params[:line])

    respond_to do |format|
      if @mline.save
         if params[:repete][:nombre].to_i > 0 # ici on crée les autres lignes...
            @mline.repete(params[:repete][:nombre].to_i,params[:repete][:periode])
         end
        mois=(@mline.line_date.month)-1
        format.html { redirect_to listing_lines_url(@listing,mois: mois), notice: 'Les lignes ont été créées.' }
        format.json { render json: @line, status: :created, location: @line }
      else
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

#  def update
#  end

  # DELETE /multiple_lines/1
  # DELETE /multiple_lines/1.json
  def destroy
#    @line = @listing.lines.find(params[:id])
#    @line.destroy
#    respond_to do |format|
#      format.html { redirect_to listing_lines_url(@listing) }
#      format.json { head :ok }
#    end
  end

#  def edit
#  end

   private
  def find_listing
    @listing=Listing.find(params[:listing_id])
    @organism=@listing.organism
  end

  def fill_mois
    @mois = params[:mois] || (Date.today.month - 1)
  end

end
