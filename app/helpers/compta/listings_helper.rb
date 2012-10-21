# coding: utf-8

module Compta::ListingsHelper

def open_sold_ordinalized(date)
    if date == @period.start_date
      "Soldes d'ouverture"
    else
      "Soldes au #{ordinalize_date date}"
    end
  end

end
