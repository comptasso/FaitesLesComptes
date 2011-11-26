# -*- encoding : utf-8 -*-

class PointageController < ApplicationController

  before_filter :find_bk_extract

  def index
    # on affiche les lignes non pointées et celles affectées à cet extrait
    @lines=@listing.lines.where('bank_extract_id = ? OR bank_extract_id IS NULL', @bank_extract.id)
  end

  def edit
  end

  private

  def find_bk_extract
    @bank_extract=BankExtract.find(params[:id])
    @listing=@bank_extract.listing
    @organism= @listing.organism
  rescue
    # TODO faire ici un log de l'anomalie
    flash[:notice] = "L'extrait de compte n'a pas été trouvé"
    redirect_to organisms_url
  end

end
