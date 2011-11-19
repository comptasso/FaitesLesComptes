# -*- encoding : utf-8 -*-
module LinesHelper
  def debit_credit(montant)
    if montant > -0.01 && montant < 0.01
      ''
    else
      number_with_precision(montant, precision: 2)
    end
  rescue
    ''
  end

  def two_decimals(montant)
    sprintf('%0.02f',montant)
  rescue
    '0.00'
  end

  def submenu(listing)
    t=['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',' Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
     content_tag :div, link_to('Janvier', listing_lines_path(listing, 'Janvier'=> 0))
    content_tag :div do
      t.each_with_index do |mois,i|
         link_to(mois, listing_lines_path(listing, "#{mois}"=> i)) 
      end
    end
  end
end
