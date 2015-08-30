# coding: utf-8
module Compta::BalancesHelper
  include ModalsHelper

  # Donne le titre de colonne Soldes d'ouverture si la date est le début d'un
  # exercice. Solde au ... dans le cas contraire
  def sold_at_title(date)
    if date == @period.start_date
      "Soldes d'ouverture"
    else
      "Soldes au #{l date}"
    end
  end


end

