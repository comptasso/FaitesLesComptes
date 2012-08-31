# coding: utf-8
# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::BalancesController < Compta::ApplicationController

 
  def new
     @balance = Compta::Balance.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la balance en pdf
  def show
    @balance = Compta::Balance.new( {period_id:@period.id}.merge(params[:compta_balance]) )
    if @balance.valid?
      respond_to do |format|
        format.html { render action: 'show'}
        format.js
        format.pdf  {send_data @balance.to_pdf.render('lib/pdf_document/balance.pdf.prawn') ,
          filename:"Balance #{@organism.title}.pdf"} #,  disposition:'inline'}
        format.csv { send_data @balance.to_csv(col_sep:"\t")  }  # pour éviter le problème des virgules
        format.xls { send_data @balance.to_xls(col_sep:"\t")  }
      end
    else
      respond_to do |format|
        format.html { render 'new'}
        format.js { render 'new'}
        format.pdf { redirect_to new_compta_period_balance_url(@period) }
        format.csv { redirect_to new_compta_period_balance_url(@period) }
        format.xls { redirect_to new_compta_period_balance_url(@period) }
      end
    end
  end

  def create

    @balance = Compta::Balance.new( {period_id:@period.id}.merge(params[:compta_balance]) )
    if @balance.valid?
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
