# coding: utf-8

# Classe destinée à afficher une general_book des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la general_book par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une general_book et
# affiche show
#
class Compta::GeneralBooksController < Compta::ApplicationController


  def new
     @general_book = Compta::GeneralBook.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la general_book en pdf
  def show
    parameters = {period_id:@period.id}.merge(params[:general_book])
    @general_book = Compta::GeneralBook.new(parameters )
    if @general_book.valid?
      respond_to do |format|
        format.pdf  {send_data @general_book.render_pdf,
          filename:"Grand_livre_#{@organism.title}.pdf"} #, disposition:'inline'}
      end
    else
      respond_to do |format|
        format.pdf {redirect_to new_compta_period_general_book_url(@period)}
      end
    end
  end

  def create
    parameters = {period_id:@period.id}.merge(params[:compta_general_book])
    @general_book = Compta::GeneralBook.new(parameters)
    if @general_book.valid?
      respond_to do |format|
        format.html { redirect_to  compta_period_general_book_url(@period, :general_book=>params[:compta_general_book], :format=>'pdf')}
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'new'}
        format.js {render 'new'}
      end

  end
  end




end
