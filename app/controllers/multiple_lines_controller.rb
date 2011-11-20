class MultipleLinesController < ApplicationController

  before_filter :find_listing
  before_filter :fill_mois, only: [:index, :new]


  # GET /multiple_lines
  def index
    # fait une liste de toutes les lignes multiples
    @mlines=@listing.lines.group(:copied_id)
  end

  
  ## GET /multiple_line/1/edit
  def show
    # récupérer la ligne
    @mline=@listing.lines.find(params[:id])
    # vérifier qu'on est bien sur une multiple et sinon renvoyer sur le controller line
    redirect_to listing_line_path(@listing, @mline) unless @mline.multiple
    # récupérer toutes les lignes relevant de cette écriture mutliple
    @mlines=@listing.lines.multiple(@mline.copied_id)
  end

  def new
    @mline=@listing.lines.new(line_date: Date.today.beginning_of_year.months_since(@mois.to_i))
  end

  def create

  end

  def update
  end

  def destroy
  end

  def edit
  end

   private
  def find_listing
    @listing=Listing.find(params[:listing_id])
    @organism=@listing.organism
  end

  def fill_mois
    @mois = params[:mois] || (Date.today.month - 1)
  end

end
