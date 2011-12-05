# -*- encoding : utf-8 -*-

class PointageController < ApplicationController

  before_filter :find_bk_extract

  def index
    # on affiche les lignes non pointées et celles affectées à cet extrait
    if @bank_extract.locked?
      flash[:alert]= "Un compte bancaire validé est déja pointé"
      redirect_to book_bank_extracts_url(@book)
      return
    end
    @lines=@book.lines.where('bank_extract_id = ? OR bank_extract_id IS NULL', @bank_extract.id)
  end

  def pointe
   @line=Line.find(params[:id])
   @line.update_attribute(:bank_extract_id, @bank_extract.id)
   respond_to do |format|
      format.html { redirect_to pointage_url(@bank_extract)}
      format.js
    end
   
  end

   def depointe
   @line=Line.find(params[:id])
   @line.update_attribute(:bank_extract_id, nil)
    respond_to do |format|
      format.html { redirect_to pointage_url(@bank_extract)}
      format.js
    end
   
  
  end

  private

  def find_bk_extract
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    @book=@bank_extract.book
    @organism= @book.organism
  rescue
    # TODO faire ici un log de l'anomalie
    flash[:notice] = "L'extrait de compte n'a pas été trouvé"
    redirect_to organisms_url
  end

end
