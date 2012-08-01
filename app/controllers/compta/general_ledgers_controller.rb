# coding: utf-8

# Classe destinée à afficher une general_ledger des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la general_ledger par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une general_ledger et
# affiche show
#
class Compta::GeneralLedgersController < Compta::ApplicationController


  def new
     @general_ledger = Compta::GeneralLedger.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la general_ledger en pdf
  def show
    @general_ledger = Compta::GeneralLedger.new( {period_id:@period.id}.merge(params[:general_ledger]) )
    if @general_ledger.valid?
      respond_to do |format|
        format.html { render action: 'show'}
        format.js
        format.pdf  {send_data @general_ledger.to_pdf.render('lib/pdf_document/general_ledger.pdf.prawn') ,
          filename:"GeneralLedger #{@organism.title}.pdf"} #, disposition:'inline'}
      end
    else
      respond_to do |format|
        format.html { render 'new'}
        format.js {render 'new'}
        format.pdf {render :text=>'Erreur dans la génération du grand livre'}
      end
    end
  end

  def create

    @general_ledger = Compta::GeneralLedger.new( {period_id:@period.id}.merge(params[:general_ledger]) )
    if @general_ledger.valid?
      respond_to do |format|
        format.html { render action: 'show'}
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
